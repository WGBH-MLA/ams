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

    private

    # these methods are shared between the xml and manifest parsers; they don't pass in the same amount of arguments
    def parse_rows(rows, type, asset_id, related_identifier = nil, parent_asset = nil)
      rows.map do |current_object|
        set_model(type, asset_id, current_object, parent_asset)
        add_object(current_object.symbolize_keys, type, related_identifier)
      end
    end

    def set_model(type, asset_id, current_object, parent_asset, counter = nil)
      key_count = counter || objects.select { |obj| obj[:model] == type }.size + 1
      bulkrax_identifier = current_object[:bulkrax_identifier] || Bulkrax.fill_in_blank_source_identifiers.call(type, asset_id, key_count)

      if current_object && current_object[:model].blank?
        current_object.merge!({
          model: type,
          work_identifier => bulkrax_identifier,
          title: create_title(parent_asset)
        })
      else
        # always return a bulkrax_identifier
        current_object[work_identifier] = bulkrax_identifier
      end
    end

    def create_title(parent_asset)
      # the xml parser doesn't pass an asset but the manifest parser does
      asset = parent_asset || objects.first
      return unless asset

      asset[:series_title] || asset[:title]
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
