module AAPB
  module BatchIngest
    class CSVConfigTree < Struct.new(:object_class, :ingest_type, :attributes, :children)
      include Enumerable
      def self.new_from_hash(hash)
        model = hash.fetch("object_class")
        if klass = model.constantize

          children = hash.fetch("children").map { |k| CSVConfigTree.new_from_hash(k) } || {} if hash.keys.include?("children")

          attr = (hash["attributes"] || [])
          attr.each do |attr|
            raise("Unknown attribute #{attr} configured for object class #{model}") unless attr == "id" || klass.properties.include?(attr)
          end
          children = [] if children.nil?

          ingest_type = hash.fetch("ingest_type")

          rase("Invalid ingest type, Allow types are #{valid_ingest_type.join(',')}") if valid_ingest_type.exclude?(ingest_type)

          CSVConfigTree.new(model, ingest_type, attr, children)
        end
      end

      def self.valid_ingest_type
        ["new", "update"]
      end

      def header_keys
        attr = []
        attr = if attributes.any?
                 attributes.deep_dup
               else
                 extra_attr=[]
                 if object_class == "Asset"
                   extra_attr=(AdminData.attribute_names.dup - ['id', 'created_at', 'updated_at'])
                 elsif object_class.include?("Instantiation")
                   extra_attr=(InstantiationAdminData.attribute_names.dup - ['id', 'created_at', 'updated_at'])
                 end
                 fedora_attr=object_class.constantize.properties.collect { |p| p.first.dup }
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
