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
          children = hash.fetch("children").map { |k| CSVConfigTree.new_from_hash(k) } || {} if hash.keys.include?("children")

          attr = (hash["attributes"] || [])
          attr.each do |attr|

            # Whitelisted properties are those that are defined on the model and
            # thus have a place to be saved once ingested.
            # Valkyrie::Resource models properties are in klass.fields, while ActiveFedora models properties are in klass.properties.keys
            if klass.ancestors.map(&:to_s).include?("ActiveFedora::Base")
              whitelisted_properties = klass.properties.keys
            elsif klass.ancestors.map(&:to_s).include?("Valkyrie::Resource")
              whitelisted_properties = klass.fields
            else
              raise("Invalid object class #{model}. Must be a subclass of ActiveFedora::Base or Valkyrie::Resource")
            end

            # Look for admin_data accessors from assets or physical_nstantiations.
            # If one of them is there, add their attribute names to the whitelisted properties.
            if klass.instance_methods.include?(:admin_data)
              whitelisted_properties += AdminData.attribute_names
              whitelisted_properties += Annotation.ingestable_attributes
            elsif klass.instance_methods.include?(:instantiation_admin_data)
              whitelisted_properties += InstantiationAdminData.attribute_names
            end

            # Convert whitelisted properties to strings for comparison, since
            # that's how they are comming in from the CSV config yaml and in the
            # case of Valkyrie models, the properties are symbols.
            whitelisted_properties.map!(&:to_s)

            # Raise an error if we find a CSV config attribute that is not in the whitelisted properties for the model.
            if (attr != "id" && whitelisted_properties.exclude?(attr))
              raise("Attribute #{attr} is specified in CSV batch ingest confiuration, but '#{attr}' is not a property of the model #{model}")
            end
          end
          children = [] if children.nil?

          ingest_type = hash.fetch("ingest_type")

          raise("Invalid ingest type, Allow types are #{valid_ingest_type.join(',')}") if valid_ingest_type.exclude?(ingest_type)

          CSVConfigTree.new(model, hash.fetch("column_header", nil), ingest_type, attr, children)
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
