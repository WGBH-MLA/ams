module AMS
  module Export
    class DocumentsToCsv < ExportService
      attr_reader :object_type

      def initialize(solr_documents, object_type:, filename: nil, export_type: nil)
        raise ArgumentError.new("Not a valid object_type for CSV export") unless AMS::CsvExportExtension::CSV_FIELDS.has_key?(object_type)
        @object_type = object_type
        super(solr_documents, format: format, filename: filename, export_type: export_type)
      end

      def format
        'csv'
      end

      def process_export
        @file_path << AMS::CsvExportExtension.get_csv_header(object_type)
        @solr_documents.each do |doc|
          @file_path << doc.export_as_csv(object_type)
        end
        @file_path.close
      end

      def clean
        @file_path.unlink
      end
    end
  end
end
