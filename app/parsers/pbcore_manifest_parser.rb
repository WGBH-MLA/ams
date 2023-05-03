class PbcoreManifestParser < Bulkrax::XmlParser
  include Bulkrax::PbcoreParserBehavior
  attr_accessor :objects, :record_objects, :manifest_hash

  def create_works
    self.record_objects = []
    set_objects.each_with_index do |record, index|
      break if limit_reached?(limit, index)

      seen[record[work_identifier]] = true
      new_entry = find_or_create_entry(entry_class, record[work_identifier], 'Bulkrax::Importer', record.compact)

      if record[:delete].present?
        Bulkrax::DeleteWorkJob.send(perform_method, new_entry, current_run)
      else
        Bulkrax::ImportWorkJob.send(perform_method, new_entry.id, current_run.id)
      end

      increment_counters(index)
    end
    importer.record_status
  rescue StandardError => e
    status_info(e)
  end

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
          if MIME::Types.type_for(md).include?('text/csv')
            csv_data = Bulkrax::CsvEntry.read_data(md)
            @manifest_hash = {}
            csv_data.each do |row|
              @manifest_hash[row["DigitalInstantiation.filename"]] = row.to_h
            end
            next
          else
            begin
              schema = Nokogiri::XML::Schema(File.read(Rails.root.join('spec', 'fixtures', 'pbcore-2.1.xsd')))
              data = entry_class.read_data(md).xpath("//#{record_element}").first # Take only the first record
              schema_errors = schema.validate(md)
              raise Nokogiri::XML::SyntaxError, schema_errors if schema_errors.present?

              entry_class.data_for_entry(data, source_identifier).merge!({ filename: File.basename(md) })
            rescue Nokogiri::XML::SyntaxError => e
              invalid_files << { message: e, filepath: md }
            end
          end
        end.compact # No need to flatten because we take only the first record
        raise_format_errors(invalid_files) if invalid_files.present?

        records
      end
  end

  # If the import_file_path is an xml file, return that
  # Otherwise return all xml files in the given folder
  def metadata_paths
    @metadata_paths ||=
      if file? && MIME::Types.type_for(import_file_path).include?('application/xml')
        [import_file_path]
      else
        file_paths.select do |f|
          MIME::Types.type_for(f).include?('application/xml') && MIME::Types.type_for(f).include?('application/csv')
            f.include?("import_#{importerexporter.id}")
        end
      end
  end

  def setup_parents
    prnts = []
    record_objects.each do |record|
      rec = record.respond_to?(:to_h) ? record.to_h : record
      next unless rec.is_a?(Hash)

      parents = rec[:parent].is_a?(String) ? rec[:parent].split(/\s*[:;|]\s*/) : rec[:parent]
      next if parents.blank?

      prnts << { rec[work_identifier] => parents }
    end

    prnts.blank? ? prnts : prnts.inject(:merge)
  end

  def create_parent_child_relationships
    parents.each do |key, value|
      child = entry_class.where(
        identifier: key,
        importerexporter_id: importerexporter.id,
        importerexporter_type: 'Bulkrax::Importer'
      ).first

      parent = entry_class.where(
        identifier: value.first,
        importerexporter_id: importerexporter.id,
        importerexporter_type: 'Bulkrax::Importer'
      ).first

      if child.blank?
        Rails.logger.error("Expected a child entry for #{work_identifier}: #{key}.")
      elsif parent.blank?
        Rails.logger.error("Expected a parent for child entry #{child.id}.")
      end

      Bulkrax::ChildRelationshipsJob.perform_later(parent.id, [child.id], current_run.id)
    end
  rescue StandardError => e
    status_info(e)
  end

  private

  def set_objects
    self.objects = []
    asset_bulkrax_identifier = ''

    records.sort_by! do |record|
      csv_row = manifest_hash[record[:filename]]
      asset_id = csv_row['Asset.id'].strip if csv_row.keys.include?('Asset.id')

      asset_id
    end

    records.each_with_index do |file, index|
      prev_index = (index - 1).positive? ? index - 1 : 0
      prev_csv_row = manifest_hash[records[prev_index][:filename]]
      prev_asset_id = prev_csv_row['Asset.id'].strip
      csv_row = manifest_hash[file[:filename]]
      asset_id = csv_row['Asset.id'].strip if csv_row.keys.include?('Asset.id')
      asset = Asset.find(asset_id)
      manifest_filename = get_manifest_filename(csv_row)
      digital_instantiation = DigitalInstantiation.where(local_instantiation_identifier: manifest_filename).first
      pbcore = PBCore::Instantiation.parse(file[:data])
      tracks = pbcore.essence_tracks

      asset_bulkrax_identifier =  if asset.bulkrax_identifier
                                    asset.bulkrax_identifier
                                  else
                                    Bulkrax.fill_in_blank_source_identifiers.call("Asset", asset_id, 1)
                                  end
      asset.update(bulkrax_identifier: asset_bulkrax_identifier) if asset.bulkrax_identifier.nil?
      add_object(asset.attributes.symbolize_keys, 'Asset', nil) if index == 0 || prev_asset_id != asset_id

      di_bulkrax_identifier = build_digital_instantiations(file, csv_row, digital_instantiation, index, asset)
      # essence tracks don't have a unique identifier so importing the same one repeatedly, will create multiple identical models
      build_essence_tracks(tracks, index, di_bulkrax_identifier, asset)
    end

    self.objects
  end

  def add_object(current_object, type, related_identifier)
    unless type == 'Asset'
      current_object[:parent] ||= []
      current_object[:parent] << related_identifier
    end

    record_objects << current_object
    objects << current_object
  end

  def get_manifest_filename(csv_row)
    # the filename in the manifest has extra info we don't need
    csv_row["DigitalInstantiation.filename"].split('.')[0..1].join('.')
  end

  def build_digital_instantiations(file, csv_row, digital_instantiation, index, asset)
    current_object = [AAPB::BatchIngest::PBCoreXMLMapper.new(file[:data]).digital_instantiation_attributes.merge!(
      {
        filename: file[:filename],
        pbcore_xml: file[:data],
        skip_file_upload_validation: true,
        instantiation_admin_data_gid: get_instantiation_admin_data_gid(csv_row, digital_instantiation),
      }
    )].first
    # unable to call the conditional inside the merged object
    current_object = current_object.merge!({ bulkrax_identifier: digital_instantiation.bulkrax_identifier }) if digital_instantiation.present?
    type = 'DigitalInstantiation'

    obj = set_model(type, index, current_object, asset)
    add_object(current_object.symbolize_keys, type, asset.bulkrax_identifier)

    obj[:bulkrax_identifier]
  end

  def build_essence_tracks(tracks, index, di_bulkrax_identifier, asset)
    parse_rows(tracks.map { |track| AAPB::BatchIngest::PBCoreXMLMapper.new(track.to_xml).essence_track_attributes }, 'EssenceTrack', index, di_bulkrax_identifier, asset)
  end

  def get_instantiation_admin_data_gid(csv_row, digital_instantiation = nil)
    if digital_instantiation.present?
      digital_instantiation.instantiation_admin_data_gid
    else
      InstantiationAdminData.create(
        aapb_preservation_lto: csv_row["DigitalInstantiation.aapb_preservation_lto"],
        aapb_preservation_disk: csv_row["DigitalInstantiation.aapb_preservation_disk"],
        md5: csv_row["DigitalInstantiation.md5"]
      ).gid
    end
  end
end
