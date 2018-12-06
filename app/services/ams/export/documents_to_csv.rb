module AMS
  module Export
    class DocumentsToCsv < ExportService
      def initialize(solr_documents, options={}, format = 'csv', filename = nil)
        raise ArgumentError.new("Need to supply an object_type option for CSV export") unless options.has_key?(:object_type)
        raise ArgumentError.new("Not a valid object_type for CSV export") unless AMS::CsvExportExtension::CSV_FIELDS.has_key?(options[:object_type])
        super
      end

      def process_export
        @file_path << AMS::CsvExportExtension.get_csv_header(@object_type)
        @solr_documents.each do |doc|
          @file_path << doc.export_as_csv(@object_type)
        end
        @file_path.close
      end

      def clean
        @file_path.unlink
      end
    end
  end
end
