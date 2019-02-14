require 'roo'

module AAPB
  module BatchIngest
    class CSVReader < AAPB::BatchIngest::BatchReader

      def delete_manifest
        File.delete(@source_location) if File.exist?(@source_location)
      end

      private

      def perform_read
        begin
          @workbook = Roo::Spreadsheet.open(@source_location)
          @workbook.default_sheet = @workbook.sheets[0]
          @header = @workbook.row(1)
          validate_options
          validate_csv_header
          read_and_create_batch_items

        rescue StandardError => e
          raise Hyrax::BatchIngest::ReaderError, I18n.t('hyrax.batch_ingest.readers.errors.invalid_source_location', source_location: source_location + " " + e.message)
        end
      end

      def validate_options
        @options_structure = AAPB::BatchIngest::CSVConfigParser.validate_config(@options)
      end

      def validate_csv_header
        configured_keys = @options_structure.header_keys.sort
        @header.sort.each do |key|
          raise("Unknown column `#{key}` Unable to parse CSV.") if configured_keys.exclude?(key)
        end
      end

      def read_and_create_batch_items
        @batch_items = []

        ((@workbook.first_row + 1)..@workbook.last_row).each do |row|
          rowData = []
          ((@workbook.first_column)..@workbook.last_column).each do |col|
            rowData << [@workbook.cell(1, col), @workbook.cell(row, col).to_s]
          end
          formatted_row_data = csv_row_to_hash(rowData)
          @batch_items << Hyrax::BatchIngest::BatchItem.new(id_within_batch: row,
                                                            source_data: formatted_row_data.to_json, status: :initialized)
        end
      end

      def csv_row_to_hash(data)
        model_hash = Hash.new()

        data.each do |val|

          (col, element) = val
          (model, attribute) = col.split(".", 2)


          value = element.strip
          if !attribute.nil? && attribute != "id" && model.constantize.properties[attribute].multiple?
            value = Array(value) unless element.strip.empty?
          end

          if model.include?(@options_structure.object_class)
            if attribute.nil?
              model_hash[model] ||= {}
            else
              model_hash[model][attribute] = value unless value.empty?
            end
          else
            if attribute.nil?

              model_hash[model] ||= [{}]

            else

              last_hash = model_hash[model].last
              last_hash[attribute] = value unless value.empty?
            end
          end

        end
        validate_row_data model_hash, @options_structure
      end

      def validate_row_data row, node, child_node = nil
        fail_row = false
        if node.ingest_type == "update"
          if child_node
            row[node.object_class].each do |c_data|
              if c_data.to_a.flatten.exclude?("id")
                raise("Must contain column `id` for #{node.object_class} for updating object.")
              end
            end
          else
            if row[node.object_class].to_a.flatten.exclude?("id")
              raise("Must contain column `id` for #{node.object_class} for updating object.")
            end
          end

        end

        node.children.each do |c|
          validate_row_data row, c, true
        end
        return row
      end
    end
  end
end
