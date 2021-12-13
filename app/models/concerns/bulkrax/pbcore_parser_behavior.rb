module Bulkrax
  module PbcoreParserBehavior
    def entry_class
      Bulkrax::PbcoreXmlEntry
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

    private

    def parse_rows(rows, type, index)
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

    def raise_format_errors(invalid_files)
      return unless invalid_files.present?

      error_msg = invalid_files.map do |failure|
        "#{failure[:message]}, in file: #{failure[:filepath]}"
      end
      raise "#{ error_msg.count == 1 ? error_msg.first : error_msg.join(" ****** ")}"
    end
  end
end