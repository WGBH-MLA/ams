module AAPB
  module BatchIngest
    class CSVConfigTree < Struct.new(:object_class, :ingest_type, :attributes, :children)
      include Enumerable

      # Map old model names to new Resource model names
      def self.map_legacy_model_name(model_name)
        legacy_mapping = {
          'Asset' => 'AssetResource',
          'PhysicalInstantiation' => 'PhysicalInstantiationResource',
          'DigitalInstantiation' => 'DigitalInstantiationResource',
          'EssenceTrack' => 'EssenceTrackResource',
          'Contribution' => 'ContributionResource'
        }
        legacy_mapping[model_name] || model_name
      end

      def self.new_from_hash(hash)
        model = hash.fetch("object_class")
        resource_model = map_legacy_model_name(model)
        if klass = resource_model.constantize

          children = hash.fetch("children").map { |k| CSVConfigTree.new_from_hash(k) } || {} if hash.keys.include?("children")

          attr = (hash["attributes"] || [])
          attr.each do |attr|
            # Look for admin_data accessors from assets or physical_nstantiations.
            # If one of them is there, add their attribute names to the whitelisted properties.
            whitelisted_properties = klass.respond_to?(:schema) ? klass.fields : klass.properties.keys

            if klass.instance_methods.include?(:admin_data)
              whitelisted_properties += AdminData.attribute_names
              whitelisted_properties += Annotation.ingestable_attributes
            elsif klass.instance_methods.include?(:instantiation_admin_data)
              whitelisted_properties += InstantiationAdminData.attribute_names
            end

            # For Valkyrie resources, also check if attribute exists in schema (includes inherited attributes)
            attribute_valid = attr == "id" || whitelisted_properties.include?(attr)
            if !attribute_valid && klass.respond_to?(:schema)
              # Try to get the schema key - this will work for inherited attributes too
              attribute_valid = klass.schema.key(attr.to_sym).present? rescue false
            end

            raise("Unknown attribute #{attr} configured for object class #{model}") unless attribute_valid
          end
          children = [] if children.nil?

          ingest_type = hash.fetch("ingest_type")

          raise("Invalid ingest type, Allow types are #{valid_ingest_type.join(',')}") if valid_ingest_type.exclude?(ingest_type)

          CSVConfigTree.new(model, ingest_type, attr, children)
        end
      end

      def self.valid_ingest_type
        ["new", "update", "add"]
      end

      def header_keys
        attr = []
        resource_class_name = self.class.map_legacy_model_name(object_class)

        attr = if attributes.any?
                 attributes.deep_dup
               else
                 extra_attr=[]
                 if object_class.include?("Asset")
                   extra_attr=(AdminData.attribute_names.dup - ['id', 'created_at', 'updated_at'] + Annotation.ingestable_attributes).uniq
                 elsif object_class.include?("Instantiation")
                   extra_attr=(InstantiationAdminData.attribute_names.dup - ['id', 'created_at', 'updated_at'])
                 end
                 fedora_attr=resource_class_name.constantize.fields.map { |f| f.to_s.dup }
                 fedora_attr.concat(extra_attr.deep_dup)
               end

        attr.collect { |a| a.prepend(object_class + ".") }

        [[object_class] + attr + children.collect(&:header_keys)].flatten
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
