class PbcoreXmlParser < Bulkrax::XmlParser
  include Bulkrax::PbcoreParserBehavior
  attr_accessor :objects, :record_objects

  # OVERRIDE BULKRAX 1.0.2 to capture format errors
  # For multiple, we expect to find metadata for multiple works in the given metadata file(s)
  # For single, we expect to find metadata for a single work in the given metadata file(s)
  #  if the file contains more than one record, we take only the first
  # In either case there may be multiple metadata files returned by metadata_paths
  def records(_opts = {})
    invalid_files = []
    @records ||=
      if parser_fields['import_type'] == 'multiple'
        r = []
        metadata_paths.map do |md|
          # Retrieve all records
          elements = entry_class.read_data(md).xpath("//#{record_element}")
          r += elements.map { |el| entry_class.data_for_entry(el, source_identifier) }
        end
        # Flatten because we may have multiple records per array
        r.compact.flatten
      elsif parser_fields['import_type'] == 'single'
        records = metadata_paths.map do |md|
          begin
            data = entry_class.read_data(md).xpath("//#{record_element}").first # Take only the first record
            entry_class.data_for_entry(data, source_identifier)
          rescue Nokogiri::XML::SyntaxError => e
            invalid_files << { message: e, filepath: md }
          end
        end.compact # No need to flatten because we take only the first record
        # OVERRIDE BULKRAX 1.0.2 to capture format errors
        raise_format_errors(invalid_files) if invalid_files.present?
        records
      end
  end

  # If the import_file_path is an xml file, return that
  # Otherwise return all xml files in the given folder
  # modified to strip extra path check
  def metadata_paths
    @metadata_paths ||=
      if file? && MIME::Types.type_for(import_file_path).include?('application/xml')
        [import_file_path]
      else
        file_paths.select do |f|
          MIME::Types.type_for(f).include?('application/xml')
        end
      end
  end

  def create_works
    self.record_objects = []
    records.each_with_index do |file, index|
      set_objects(file, index).each do |record|
        break if limit_reached?(limit, index)

        seen[record[work_identifier]] = true
        new_entry = find_or_create_entry(entry_class, record[work_identifier], 'Bulkrax::Importer', record.compact)
        if record[:delete].present?
          Bulkrax::DeleteWorkJob.send(perform_method, new_entry, current_run)
        else
          Bulkrax::ImportWorkJob.send(perform_method, new_entry.id, current_run.id)
        end
      end
      increment_counters(index)
    end
    importer.record_status
  rescue StandardError => e
    status_info(e)
  end

  ##
  # This method is useful for updating existing entries with out reimporting the works themselves
  # used in scripts and on the console
  def recreate_entries
    self.record_objects = []
    records.each_with_index do |file, index|
      set_objects(file, index).each do |record|
        break if limit_reached?(limit, index)

        seen[record[work_identifier]] = true
        new_entry = find_or_create_entry(entry_class, record[work_identifier], 'Bulkrax::Importer', record.compact)
      end
      increment_counters(index)
    end
    importer.record_status
  rescue StandardError => e
    status_info(e)
  end

  ##
  # This method sets up the records and objects without changing entries or works. Useful for debugging
  # and correcting imports that are having data issues
  def reload_objects
    self.record_objects = []
    records.each_with_index do |file, index|
      set_objects(file, index).each do |record|
        break if limit_reached?(limit, index)
        seen[record[work_identifier]] = true
      end
      increment_counters(index)
    end
  rescue StandardError => e
    status_info(e)
  end

  def total
    records.size
  rescue RuntimeError => e
    nil
  end

  def setup_parents
    parents = []
    importer.entries.where('raw_metadata REGEXP ?', '.*children\":\[.+\].*')
  end

  # Will be skipped unless the #record is a Hash
  def create_parent_child_relationships
    parents.each do |parent|
      # not finding the entries here indicates that the given identifiers are incorrect
      # in that case we should log that
      children = parent.raw_metadata.with_indifferent_access[:children].map do |child_id|
        importer.entries.find_by(identifier: child_id)
      end

      Bulkrax::ChildRelationshipsJob.perform_later(parent.id, children.map(&:id), current_run.id) if parent.present? && children.present?
    end
  rescue StandardError => e
    status_info(e)
  end

  private

  def set_objects(file, index)
    self.objects = []
    current_object = {}
    instantiations = PBCore::DescriptionDocument.parse(file[:data]).instantiations

    # we are checking to see if these models already exist so that we update them instead of creating duplicates
    xml_asset = AAPB::BatchIngest::PBCoreXMLMapper.new(file[:data]).asset_attributes.merge!({ delete: file[:delete], pbcore_xml: file[:data] })
    xml_asset[:children] = []
    asset_id = xml_asset[:id]
    asset = Asset.where(id: xml_asset[:id])&.first
    asset_attributes = asset&.attributes&.symbolize_keys
    xml_asset = asset_attributes.merge(xml_asset) if asset_attributes
    parse_rows([xml_asset], 'Asset', asset_id)
    add_object(xml_asset)
    instantiation_rows(instantiations, xml_asset, asset, asset_id)
    objects
  end

  def instantiation_rows(instantiations, xml_asset, asset, asset_id)
    xml_records = []
    instantiations.each.with_index do |inst, i|
      instantiation_class =  'PhysicalInstantiation' if inst.physical
      instantiation_class ||= 'DigitalInstantiation' if inst.digital
      next unless instantiation_class
      xml_record = AAPB::BatchIngest::PBCoreXMLMapper.new(inst.to_xml).send("#{instantiation_class.to_s.underscore}_attributes").merge!({ pbcore_xml: inst.to_xml, skip_file_upload_validation: true })
      # Find members of the asset that have the same class and local identifier. If no asset, then no digital instantiation can exist
      instantiation = asset.members[i] if asset && asset.members[i]&.class == instantiation_class.constantize
      xml_record = instantiation.attributes.symbolize_keys.merge(xml_record) if instantiation
      xml_record[:children] = []
      # we accumulate the tracks here so that they are added to the bulkrax entries list in the order they appear in the pbcore xml
      xml_tracks = []
      inst.essence_tracks.each.with_index do |track, j|
        xml_track = AAPB::BatchIngest::PBCoreXMLMapper.new(track.to_xml).essence_track_attributes.merge({ pbcore_xml: track.to_xml })
        essence_track = instantiation.members[j] if instantiation&.members&.[](j)&.class == EssenceTrack
        xml_track = essence_track.attributes.symbolize_keys.merge(xml_track) if essence_track
        parse_rows([xml_track], 'EssenceTrack', asset_id, asset, j+1)
        xml_record[:children] << xml_track[work_identifier]
        xml_tracks << xml_track
      end
      parse_rows([xml_record], instantiation_class, asset_id, asset)
      add_object(xml_record)
      xml_tracks.each { |xml_track| add_object(xml_track) }
      xml_records << xml_record
    end
    xml_records.each do |row|
      xml_asset[:children] << row[work_identifier]
    end
  end

  def parse_rows(rows, type, asset_id, parent_asset = nil, counter = nil)
    rows.map do |current_object|
      set_model(type, asset_id, current_object, parent_asset, counter)
    end
  end

  def add_object(current_object)
    if current_object.present?
      record_objects << current_object
      objects << current_object
    end
  end

  def set_instantiation_children(record)
    initial_importer_id = record[work_identifier].first
    initial_child_identifier = record[work_identifier].gsub(record[:model], 'EssenceTrack')

    current_importer_id = importerexporter.id.to_s
    current_child_identifier = initial_child_identifier.sub(initial_importer_id, current_importer_id)

    if objects.first[:children].include?(initial_child_identifier)
      # we are importing this file for the first time
      # or re-running the importer where this file was first imported
      record[:children] ||= []
      record[:children] << initial_child_identifier
      objects.first[:children].delete(initial_child_identifier)
    end

    if objects.first[:children].include?(current_child_identifier)
      # we are importing the same file we imported in a different importer
      # essence tracks aren't legitimate children of an asset though so we remove it
      # and do not create a duplicate relation with the parent DI or PI
      objects.first[:children].delete(current_child_identifier)
    end

    record_objects.find { |r| r[work_identifier] == record[work_identifier] }.merge!({ children: [initial_child_identifier] })
    # return the record so that we retain the parent/child relationships
    record
  end
end
