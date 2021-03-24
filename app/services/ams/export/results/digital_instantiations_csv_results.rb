module AMS
  module Export
    module Results
      class DigitalInstantiationsCSVResults < CSVResults
        def write_to_file
          CSV.open(filepath, 'w+') do |csv|
            csv_data('digital_instantiation').each do |csv_row|
              csv << csv_row
            end
          end
        end

        def filename
          "export-digital-instantiations-#{timestamp}.csv"
        end
      end
    end
  end
end
