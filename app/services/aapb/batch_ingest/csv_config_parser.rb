module AAPB
  module BatchIngest
    class CSVConfigTree < Struct.new(:object_class, :column_header, :ingest_type, :attributes, :children)
      # TODO: This configuration file is pretty confusing and could really use a
      # refactor. The basic job here is to parse config/batch_ingest.yml and
      # return a tree of objects that represent the structure of the CSV file to
      # be ingested, and to make sure the config file is valid.
      include Enumerable

      def self.new_from_hash(hash)
        model = hash.fetch("object_class")
        if klass = model.constantize
          # Validate the ingest type
          ingest_type = hash.fetch("ingest_type", nil)
          raise("Invalid ingest type: '#{ingest_type}', Allow types are #{valid_ingest_type.join(',')}") if valid_ingest_type.exclude?(ingest_type)

          # Validate the model class
          raise("Invalid model class, #{model} is not a subclass of Valkyrie::Resource") unless klass < Valkyrie::Resource

          # Validate children array, if any
          children = hash.fetch("children", [])
          raise 'Invalid config, children must be an array' unless children.is_a?(Array)

          # Validate that there are attributes
          ingest_attrs = hash.fetch("attributes", [])
          raise "Invalid config, an array of attributes must be defined for object '#{klass}'" unless ingest_attrs.is_a?(Array) && ingest_attrs.any?

          # Return a new CSVConfigTree object with the validated values
          # The children are recursively parsed into CSVConfigTree objects as well.
          CSVConfigTree.new(
            model,
            hash.fetch("column_header", nil),
            ingest_type,
            hash['attributes'],
            children.map { |child_config| CSVConfigTree.new_from_hash(child_config)}
          )
        end
      end

      def self.valid_ingest_type
        ["new", "update", "add"]
      end

      def header_keys
        # The header_keys (aka column headers) are the object column header, the
        # attribute column headers, and the header keys of any children. Here we
        # gather them all into a single array and flatten it to a single level
        # to represent the header row of the ingest CSV file.
        [
          object_column_header,
          attribute_column_headers,
          children.map(&:header_keys)
        ].flatten
      end

      # The object_class in config/batch_ingest.yml defines which class to use.
      # WE ONLY USE THE VALKYRIE MODELS NOW that end in "Resource", e.g. we use
      # `AssetResource`, not the old ActiveFedora `Asset`.
      # However we want the ingesters to be able to use the old names in the
      # headers of the ingest CSV file, which they can now specify with the column_header key in config/batch_ingest.yml.
      # and it should still work).
      # This method return column_header if specified, or object_class if not,
      # and allows the CSV ingester in various places to find the correct data in the CSV file.
      def object_column_header
        column_header ? column_header : object_class
      end

      # Return a list of attributes prepended with the object column header, e.g. "Asset.title", "Asset.description", etc.
      # Representing the column headers of each asset and allowing the CSV ingester to find the cell in each row.
      def attribute_column_headers
        attributes.map do |attribute|
          "#{object_column_header}.#{attribute}"
        end
      end
    end

    class CSVConfigParser
      def self.validate_config(options)
        CSVConfigTree.new_from_hash(options.fetch(:schema).first.deep_dup)
      rescue StandardError => e
        raise Hyrax::BatchIngest::ReaderError, "Error Parsing Reader Options. Error:" + e.message
      end
    end
  end
end
