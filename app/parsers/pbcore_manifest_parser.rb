class PbcoreManifestParser < Bulkrax::XmlParser
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

  # Return all files in the import directory and sub-directories
  def file_paths
    @file_paths ||=
      # Relative to the file
      if file? && zip?
        Dir.glob("#{importer_unzip_path}/**/*").reject { |f| File.file?(f) == false }
      elsif file? 
        Dir.glob("#{File.dirname(parser_fields['import_file_path'])}/**/*").reject { |f| File.file?(f) == false }
      # In the supplied directory
      else
        Dir.glob("#{parser_fields['import_file_path']}/**/*").reject { |f| File.file?(f) == false }
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

  # Optional, only used by certain parsers
  # Other parsers should override with a custom or empty method
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
      parent_id = parent.id
      child_entry_ids = children.map(&:id)
      Bulkrax::ChildRelationshipsJob.perform_later(parent_id, child_entry_ids, current_run.id)
    end
  rescue StandardError => e
    status_info(e)
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
      })], 'DigitalInstantiation', index, current_object)
    new_rows += parse_rows(tracks.map { |track| AAPB::BatchIngest::PBCoreXMLMapper.new(track.to_xml).essence_track_attributes }, 'EssenceTrack', index, current_object)
    
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

  def parse_rows(rows, type, index, current_object)
    rows.each do |object|
      set_model(type, index, object)
      add_object(object.symbolize_keys)
    end
  end

  def set_model(type, index, current_object)
    if current_object && !current_object.keys.include?(:model)
      key_count = objects.select { |obj| obj[:model] == type }.size + 1
      current_object.merge!({
        model: type,
        work_identifier => Bulkrax.fill_in_blank_source_identifiers.call(self, "#{type}-#{index}-#{key_count}"),
      })
    end
  end

  def add_object(current_object)
    if current_object.present?
      if objects.first
        objects.first[:children] ||= []
        objects.first[:children] << current_object[work_identifier] if current_object[work_identifier].present?
      end
      record_objects << current_object
      objects << current_object
    end
  end

  def set_digital_instantiation_children(record)
    child_identifer = record[work_identifier].gsub('DigitalInstantiation', 'EssenceTrack')
    if objects.first[:children].include?(child_identifer)
      record[:children] ||= []
      record[:children] << child_identifer 
      objects.first[:children].delete(child_identifer)
    end
    record_objects.find { |r| r[work_identifier] == record[work_identifier]}.merge!({ children: [child_identifer] })
  end
end
