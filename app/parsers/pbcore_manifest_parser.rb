class PbcoreManifestParser < Bulkrax::XmlParser
  include Bulkrax::PbcoreParserBehavior
  attr_accessor :objects, :record_objects, :manifest_hash

  def create_works
    self.record_objects = []
    records.each_with_index do |file, index|
      set_objects(file, index).each do |record|
        break if limit_reached?(limit, index)
        if record[:model] == 'DigitalInstantiation'
          record = set_digital_instantiation_children(record)
          record.merge!(manifest_hash[record[:filename]])
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

  # In either case there may be multiple metadata files returned by metadata_paths
  def records(_opts = {})
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
        metadata_paths.map do |md|
          if MIME::Types.type_for(md).include?('text/csv')
            csv_data = Bulkrax::CsvEntry.read_data(md)
            @manifest_hash = {}
            csv_data.each do |row|
              @manifest_hash[row["DigitalInstantiation.filename"]] = row.to_h
            end
            next
          else
            data = entry_class.read_data(md).xpath("//#{record_element}").first # Take only the first record
            entry_class.data_for_entry(data, source_identifier).merge!({filename: File.basename(md)})
          end
        end.compact # No need to flatten because we take only the first record
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
    pts = []
    record_objects.each do |record|
      r = if record.respond_to?(:to_h)
            record.to_h
          else
            record
          end
      next unless r.is_a?(Hash)
      children = if r[:children].is_a?(String)
                    r[:children].split(/\s*[:;|]\s*/)
                  else
                    r[:children]
                  end
      next if children.blank?
      pts << {
        r[work_identifier] => children
      }
    end
    pts.blank? ? pts : pts.inject(:merge)
  end

  private

  def set_objects(file, index)
    self.objects = []
    current_object = {}
    new_rows = []
    csv_row = manifest_hash[file[:filename]]
    digital_instantiation = DigitalInstantiation.where(local_instantiation_identifier: csv_row["DigitalInstantiation.filename"].first)
    pbcore = PBCore::Instantiation.parse(file[:data])
    tracks = pbcore.essence_tracks

    asset_id = csv_row['Asset.id'].strip if csv_row.keys.include?('Asset.id')
    new_rows = if asset_id.present?
      work = Asset.find(asset_id) 
      set_model('Asset', index, current_object).merge!(work.attributes.symbolize_keys)
      add_object(current_object)
    end

    new_rows += parse_rows([AAPB::BatchIngest::PBCoreXMLMapper.new(file[:data]).digital_instantiation_attributes.merge!({
      filename: file[:filename],
      pbcore_xml: file[:data],
      skip_file_upload_validation: true,
      instantiation_admin_data_gid: get_instantiation_admin_data_gid(csv_row, digital_instantiation)
      })], 'DigitalInstantiation', index)
    new_rows += parse_rows(tracks.map { |track| AAPB::BatchIngest::PBCoreXMLMapper.new(track.to_xml).essence_track_attributes }, 'EssenceTrack', index)
    
    new_rows
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
