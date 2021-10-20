class PbcoreXmlParser < Bulkrax::XmlParser
  attr_accessor :objects, :record_objects
  def create_works
    self.record_objects = []
    records.each_with_index do |file, index|
      set_objects(file, index).each do |record|
        break if limit_reached?(limit, index)
        record = set_digital_instantiation_children(record) if record[:model] == 'DigitalInstantiation'
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
    instantiations = PBCore::DescriptionDocument.parse(file[:data]).instantiations
    pbcore_physical_instantiations = instantiations.select { |inst| inst.physical }
    pbcore_digital_instantiations = instantiations.select { |inst| inst.digital }
    tracks = instantiations.map(&:essence_tracks).flatten # processed in the digitial inst. actor. if we comment this out it will not
    # show up in the bulkrax importer, but the records still get processed in the actor.
    # people/contributor is processed as part of the asset_attributes method
    new_rows += parse_rows([AAPB::BatchIngest::PBCoreXMLMapper.new(file[:data]).asset_attributes.merge!({ delete: file[:delete] })], 'Asset', index, current_object)
    new_rows += parse_rows(pbcore_physical_instantiations.map { |inst| AAPB::BatchIngest::PBCoreXMLMapper.new(inst.to_xml).physical_instantiation_attributes }, 'PhysicalInstantiation', index, current_object)
    new_rows += parse_rows(pbcore_digital_instantiations.map { |inst| AAPB::BatchIngest::PBCoreXMLMapper.new(inst.to_xml).digital_instantiation_attributes.merge!({pbcore_xml: inst.to_xml, skip_file_upload_validation: true}) }, 'DigitalInstantiation', index, current_object)
    new_rows += parse_rows(tracks.map { |track| AAPB::BatchIngest::PBCoreXMLMapper.new(track.to_xml).essence_track_attributes }, 'EssenceTrack', index, current_object)
    
    new_rows
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
        title: create_title
      })
    end
  end

  def create_title(work = nil)
    asset = objects.first
    return unless asset
   
    asset[:series_title]
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
