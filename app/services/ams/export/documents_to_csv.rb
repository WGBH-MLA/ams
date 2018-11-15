module AMS
  module Export
    class DocumentsToCsv < ExportService
      def initialize(solr_documents, format = "csv", filename = nil)
        super
      end

      def process_export
        @file_path << AMS::CsvExportExtension.get_csv_header
        @solr_documents.each do |doc|
          @file_path << doc.export_as_csv
        end
        @file_path.close
      end

      def clean
        @file_path.unlink
      end
    end
  end
end
