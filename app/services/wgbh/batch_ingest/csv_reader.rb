require 'roo'

module WGBH
  module BatchIngest
    class CSVReader < WGBH::BatchIngest::BatchReader
      private

        def perform_read
          # TODO: Check if submitter_email have access to admin_set before performing read
          # Ability.can?(:deposit,admin_set)
          begin
            workbook = Roo::Spreadsheet.open(@source_location)


            workbook.default_sheet = workbook.sheets[0]


            @batch_items = []

            ((workbook.first_row + 1)..workbook.last_row).each do |row|
              rowData = []
              ((workbook.first_column)..workbook.last_column).each do |col|
                raise("Error!, can not process element #{workbook.cell(1,col)}") if workbook.cell(1,col).include?(".id")
                rowData << [workbook.cell(1,col),workbook.cell(row,col).to_s]
              end
              formatted_row_data = source_data_to_model_hash(rowData)
              raise("Error!, Could not find Asset record.") if !formatted_row_data.keys.include?("Asset")

              @batch_items <<  Hyrax::BatchIngest::BatchItem.new(id_within_batch: row,
                                                                 source_data: formatted_row_data.to_json, status: :initialized)
            end
          rescue StandardError => e
            raise Hyrax::BatchIngest::ReaderError, I18n.t('hyrax.batch_ingest.readers.errors.invalid_source_location', source_location: source_location + " " +e.backtrace)
          end
        end

        def source_data_to_model_hash(data)
          model_hash = Hash.new()

          data.each do |val|

            (col,element) = val
            (model,attribute) = col.split(".",2)

            #raise ("Unknown attribute #{"attribute"} for model #{model}") if attribute.nil? || !model.constantize.properties.include?(attribute)

            #parent
            #
            value = element.strip
            if !attribute.nil? && model.constantize.properties[attribute].multiple?
              value = Array(value) unless element.strip.empty?
            end

            if model.include?("Asset")
              if attribute.nil?
                model_hash[model] ||= {}
                model_hash[model]["admin_set_id"] = "admin_set/default"
              else
                model_hash[model][attribute] = value unless value.empty?
              end
            else
              if attribute.nil?
                #add adminset hash into array
                #
                model_hash[model] ||= []
                model_hash[model] << []
                model_hash[model].last.push({"admin_set_id" => "admin_set/default"})
              else
                last_hash = model_hash[model].last.last
                last_hash[attribute] = value unless value.empty?
              end
            end

          end
          return model_hash
        end
    end
  end
end
