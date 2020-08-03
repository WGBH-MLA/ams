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
          raise Hyrax::BatchIngest::ReaderError, I18n.t('hyrax.batch_ingest.readers.errors.invalid_source_location', source_location: source_location + " \n" + e.message + "\n" +  e.backtrace.to_s)
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
          if multi_value_attr?(attribute, model)
            value = Array(value) unless element.strip.empty?
          end

          if model.include?('Asset')
            # an asset
            if attribute.nil?
              model_hash[model] ||= {}
            elsif annotation_attr?(attribute)
              model_hash[model]["annotations"] ||= []
              model_hash[model]["annotations"] << { "annotation_type" => attribute.to_s, "value" => value } unless value.empty?
            elsif multi_value_attr?(attribute, model)
              model_hash[model][attribute] ||= []
              model_hash[model][attribute] << value.first
            else
              model_hash[model][attribute] = value unless value.empty?
            end

          else

            # initialize array of contributions or instantiations etc
            model_hash[model] ||= []

            # not an asset
            if attribute.nil?

              # if we're on a 'new object' column, add a new blank hash to our attrs
              model_hash[model] << {}
            else

              # otherwise, pick up the last-added hash from array and fill out values
              last_hash = model_hash[model].last

              if multi_value_attr?(attribute, model)

                last_hash[attribute] ||= []
                last_hash[attribute] << value.first
              else

                last_hash[attribute] = value unless value.empty?
              end
            end
          end

        end

        validate_row_data model_hash, @options_structure
      end

      def multi_value_attr?(attribute,klass)
        if !attribute.nil? && attribute != "id" && ( instantiation_multi_attr?(attribute,klass) || multi_value_fedora_attribute?(attribute,klass) )
          return true
        end
        false
      end

      def annotation_attr?(attribute)
        !attribute.nil? && attribute != "id" && Annotation.ingestable_attributes.include?(attribute)
      end

      def multi_value_fedora_attribute?(attribute,klass)
        klass.constantize.properties[attribute] && klass.constantize.properties[attribute].multiple?
      end

      def instantiation_multi_attr?(attribute,klass)
        asset_multi_value_admin_data_attr = [:sonyci_id]
        return true if klass == "Asset" && asset_multi_value_admin_data_attr.include?(attribute.to_sym)
        false
      end

      def validate_row_data row, node, child_node = nil
        fail_row = false
        if node.ingest_type == "update" || node.ingest_type == "add"
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
