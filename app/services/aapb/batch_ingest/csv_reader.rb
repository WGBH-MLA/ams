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
          read_and_create_batch_items
        rescue StandardError => e
          raise Hyrax::BatchIngest::ReaderError, I18n.t('hyrax.batch_ingest.readers.errors.invalid_source_location', source_location: source_location + " \n" + e.message + "\n" +  e.backtrace.to_s, cause: e)
        end
      end

      def workbook
        @workbook ||= Roo::Spreadsheet.open(@source_location).tap do |wb|
          wb.default_sheet = wb.sheets[0]
        end
      end

      def header
        @header ||= workbook.row(1).tap do |h|
          header.sort.uniq.each do |key|
            raise("Unknown column `#{key}` Unable to parse CSV.") if valid_header_keys.exclude?(key)
          end
        end
      end

      def valid_header_keys
        @valid_header_keys ||= csv_reader_config.header_keys.sort
      end

      def csv_reader_config
        # NOTE: #options comes from Hyrax::BatchIngest::BatchReader.
        @csv_reader_config ||= AAPB::BatchIngest::CSVConfigParser.validate_config(options)
      end

      def read_and_create_batch_items
        @batch_items = []

        ((workbook.first_row + 1)..workbook.last_row).each do |row|
          rowData = []
          ((workbook.first_column)..workbook.last_column).each do |col|
            rowData << [workbook.cell(1, col), workbook.cell(row, col).to_s]
          end

          formatted_row_data = csv_row_to_hash(rowData)

          # We want to take the Contribution batches and put them in as a nested attribute for the Asset instead
          # this way the ingester would pass it as params, like how you would from the UI.  This way we don't
          # see it in the UI because it doesn't get created through the form with all the access controls
          formatted_row_data['Asset']['contributors'] = formatted_row_data.delete('Contribution') if formatted_row_data['Asset']

          @batch_items << Hyrax::BatchIngest::BatchItem.new(id_within_batch: row,
                                                            source_data: formatted_row_data.to_json, status: :initialized)
        end
      end

      def csv_row_to_hash(data)
        model_hash = Hash.new()

        data.each do |column_header_and_value|
          # The column_header_and_value is a 2-element array, e.g. ["Asset.title", "My Asset Title"]
          # Strip whitespace and assign to variables for clarity.
          column_header, value = column_header_and_value.map(&:strip)

          # Get the model class for the given full column header.
          # See CsvConfigParser#column_header_to_object_class.
          model = csv_reader_config.column_header_to_object_class(column_header)

          # The attribute name is what comes after the first dot in the column
          # header, nil if there is no dot or nothing after it.
          attribute = column_header.split(".")[1]&.strip

          # Ensure value is a single-valued array if the attribute is defined as
          # being multi-valued in our schema.
          value = Array(value) if multi_value_attr?(attribute, model)

          # If this column is for an AssetResource object...
          if model == AssetResource
            # If this is the first column for this AssetResource object...
            if attribute.nil?
              # Initialize a new hash for this AssetResource object if not already initialized.
              model_hash[model] ||= {}
            elsif annotation_attr?(attribute)
              # If this is an annotation attribute for this AssetResource object...
              # Initialize an array of annotations if not already initialized.
              model_hash[model]["annotations"] ||= []
              # If a value is present...
              if value.present?
                # Add a new annotation hash to the array of annotations for this AssetResource object.
                model_hash[model]["annotations"] << {
                  "annotation_type" => attribute.to_s,
                  "value" => value
                }
              end
            else
              # If this is a regular attribute for this AssetResource...
              # Add the attribute and value to the hash.
              model_hash[model][attribute] = value unless value.empty?
            end
          else
            # If the model is not an AssetResource...
            # Initialize array of Child objects if not already initialized
            model_hash[model] ||= []

            # If this is the first column for this child object...
            if attribute.nil?
              # Initialize a new hash for this child object and add it to the
              # array of child objects.
              model_hash[model] << {}
            else
              # If this is an attribute column for this child object, add the
              # attribute and value to the last hash in the array of child
              # objects if there is a value is present.
              last_hash = model_hash[model].last
              last_hash[attribute] = value unless value.empty?
            end
          end
        end

        # Return the model hash after validating that it contains the required
        # data for the ingest type specified in the config.
        validate_row_data(model_hash, csv_reader_config)
      end

      def multi_value_attr?(attribute, model)
        return false if attribute == 'id'
        return attribute.present? &&
          (
            admin_data_multivalued_attr?(attribute, model) ||
            valkyrie_multivalue_attribute?(attribute, model)
          )
      end

      def annotation_attr?(attribute)
        !attribute.nil? && attribute != "id" && Annotation.ingestable_attributes.include?(attribute)
      end

      def valkyrie_multivalue_attribute?(attribute, model)
        model.schema.key(attribute.to_sym).meta.fetch('multiple', false)
      end

      def admin_data_multivalued_attr?(attribute, model)
        asset_multi_value_admin_data_attr = [:sonyci_id]
        return true if model == "Asset" && asset_multi_value_admin_data_attr.include?(attribute.to_sym)
        false
      end

      def validate_row_data(row, node, child_node = nil)
        fail_row = false
        if node.ingest_type == "update" || node.ingest_type == "add"
          # When we update a contribution, we get rid of the old contributions and create new ones
          return row if node.object_column_header == "Contribution"

          if child_node
            row[node.object_column_header].each do |c_data|
              if c_data.to_a.flatten.exclude?("id")
                raise("Must contain column `id` for #{node.object_column_header} for updating object.")
              end
            end
          else
            if row[node.object_column_header].to_a.flatten.exclude?("id")
              raise("Must contain column `id` for #{node.object_column_header} for updating object.")
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
