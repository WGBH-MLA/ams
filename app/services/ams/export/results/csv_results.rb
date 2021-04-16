module AMS
  module Export
    module Results
      class CSVResults < Base

        def content_type; 'text/csv'; end

        private

          def csv_data(export_type)
            @csv_data ||= [].tap do |rows|
              rows << AMS::CsvExportExtension.fields_for(export_type)
              solr_documents.each do |doc|
                rows << doc.csv_row_for(export_type)
              end
            end
          end
      end
    end
  end
end
