# frozen_string_literal: true

require_dependency Bulkrax::Engine.root.join('app', 'models', 'bulkrax', 'entry')

Bulkrax::Entry.class_eval do     # rubocop:disable Metrics/ParameterLists
  # Return all files in the import directory and sub-directories
  def file_paths
    @file_paths ||=
      # Relative to the file
      self.filename = if file? && zip?
        Dir.glob("#{importer_unzip_path}/**/*").reject { |f| File.file?(f) == false }
      elsif file? 
        Dir.glob("#{File.dirname(parser_fields['import_file_path'])}/**/*").reject { |f| File.file?(f) == false }
      # In the supplied directory
      else
        Dir.glob("#{parser_fields['import_file_path']}/**/*").reject { |f| File.file?(f) == false }
      end
  end
end
