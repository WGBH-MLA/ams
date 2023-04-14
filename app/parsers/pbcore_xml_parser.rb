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

        # both instantiations can have an essence track child
        if record[:model] == 'DigitalInstantiation' || record[:model] == 'PhysicalInstantiation'
          record = set_instantiation_children(record)
        end

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

  def total
    records.size
  rescue RuntimeError => e
    nil
  end

  def setup_parents
    prnts = []
    record_objects.each do |record|
      rec = record.respond_to?(:to_h) ? record.to_h : record
      next unless rec.is_a?(Hash)

      children = rec[:children].is_a?(String) ? rec[:children].split(/\s*[:;|]\s*/) : rec[:children]
      next if children.blank?

      prnts << { rec[work_identifier] => children }
    end

    prnts.blank? ? prnts : prnts.inject(:merge)
  end

  # Will be skipped unless the #record is a Hash
  def create_parent_child_relationships
    parents.each do |key, value|
      parent = entry_class.where(
        identifier: key,
        importerexporter_id: importerexporter.id,
        importerexporter_type: 'Bulkrax::Importer'
      ).first

      # not finding the entries here indicates that the given identifiers are incorrect
      # in that case we should log that
      children = value.map do |child|
        entry_class.where(
          identifier: child,
          importerexporter_id: importerexporter.id,
          importerexporter_type: 'Bulkrax::Importer'
        ).first
      end.compact.uniq

      if parent.present? && (children.length != value.length)
        # Increment the failures for the number we couldn't find
        # Because all of our entries have been created by now, if we can't find them, the data is wrong
        Rails.logger.error("Expected #{value.length} children for parent entry #{parent.id}, found #{children.length}")
        break if children.empty?
        Rails.logger.warn("Adding #{children.length} children to parent entry #{parent.id} (expected #{value.length})")
      end

      Bulkrax::ChildRelationshipsJob.perform_later(parent.id, children.map(&:id), current_run.id)
    end
  rescue StandardError => e
    status_info(e)
  end

  private

  def set_objects(file, index)
    self.objects = []
    current_object = {}
    new_rows = []
    instantiations = PBCore::DescriptionDocument.parse(file[:data]).instantiations
    pbcore_physical_instantiations = instantiations.select { |inst| inst.physical }
    pbcore_digital_instantiations = instantiations.select { |inst| inst.digital }
    tracks = instantiations.map(&:essence_tracks).flatten # processed in the digitial inst. actor. if we comment this out it will not
    # show up in the bulkrax importer, but the records still get processed in the actor.
    # people/contributor is processed as part of the asset_attributes method

    # we are checking to see if these models already exist so that we update them instead of creating duplicates
    xml_asset = AAPB::BatchIngest::PBCoreXMLMapper.new(file[:data]).asset_attributes.merge!({ delete: file[:delete] })
    asset = Asset.where(id: xml_asset[:id]).first&.attributes&.symbolize_keys
    xml_asset = asset.merge!(xml_asset) if asset
    new_rows += parse_rows([xml_asset], 'Asset', index)

    pi_rows = pbcore_physical_instantiations.map do |inst|
      xml_pi = AAPB::BatchIngest::PBCoreXMLMapper.new(inst.to_xml).physical_instantiation_attributes
      # Find members of the asset that have the same class and local identifier. If no asset, then no physical instantiation can exist
      physical_instantiation = asset.members.detect do |member|
          member.local_instantiation_identifier == xml_pi[:local_instantiation_identifier] && member.class == PhysicalInstantiation
      end if asset && xml_pi[:local_instantiation_identifier].present?
      xml_pi = physical_instantiation.merge!(xml_pi) if physical_instantiation

      xml_pi
    end
    new_rows += parse_rows(pi_rows, 'PhysicalInstantiation', index)

    di_rows = pbcore_digital_instantiations.map do |inst|
      xml_di = AAPB::BatchIngest::PBCoreXMLMapper.new(inst.to_xml).digital_instantiation_attributes.merge!({ pbcore_xml: inst.to_xml, skip_file_upload_validation: true })
      # Find members of the asset that have the same class and local identifier. If no asset, then no digital instantiation can exist
      digital_instantiation = asset.members.detect do |member|
        member.local_instantiation_identifier == xml_pi[:local_instantiation_identifier] && member.class == DigitalInstantiation
      end if asset && xml_pi[:local_instantiation_identifier].present?
      xml_di = digital_instantiation.merge!(xml_di) if digital_instantiation

      xml_di
    end
    new_rows += parse_rows(di_rows, 'DigitalInstantiation', index)

    # essence tracks don't have a unique identifier, so importing the same one repeatedly will create multiple identical models
    et_rows = tracks.map { |track| AAPB::BatchIngest::PBCoreXMLMapper.new(track.to_xml).essence_track_attributes }
    new_rows += parse_rows(et_rows, 'EssenceTrack', index)

    new_rows
  end

  def add_object(current_object, type, related_identifier)
    if current_object.present?
      # each xml file only has one asset, so it will be the first object
      if objects.first
        objects.first[:children] ||= []
        objects.first[:children] << current_object[work_identifier]
      end

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
