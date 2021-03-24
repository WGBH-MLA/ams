module AMS
  module Export
    module Results
      class PhysicalInstantiationsCSVResults < CSVResults
        private          
          def write_to_file
            CSV.open(filepath, 'w+') do |csv|
              csv_data('physical_instantiation').each do |csv_row|
                csv << csv_row
              end
            end
          end

          def filename
            "export-physical-instantiations-#{timestamp}.csv"
          end
      end
    end
  end
end
