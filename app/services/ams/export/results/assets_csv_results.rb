module AMS
  module Export
    module Results
      class AssetsCSVResults < CSVResults
        private

          def write_to_file
            CSV.open(filepath, 'w+') do |csv|
              csv_data('asset').each do |csv_row|
                csv << csv_row
              end
            end
          end

          def filename
            "export-assets-#{timestamp}.csv"
          end
      end
    end
  end
end
