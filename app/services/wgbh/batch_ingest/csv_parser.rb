module WGBH
  module BatchIngest

    class CSVConfigTree < Struct.new(:object_class, :ingest_type, :attributes, :children)
      include Enumerable
      def self.new_from_hash(hash)
        model = hash.fetch("object_class")
        if klass = model.constantize

          if hash.keys.include?("children")
            children = hash.fetch("children").map{ |k|  CSVConfigTree.new_from_hash(k)} || {}
          end

          attr = (hash["attributes"] || [])
          attr.each do |attr|
              raise("Unknown attribute #{attr} configured for object class #{model}") unless attr == "id" || klass.properties.include?(attr)
          end
          children = [] if children.nil?

          ingest_type = hash.fetch("ingest_type")

          if valid_ingest_type.exclude?(ingest_type)
              rase("Invalid ingest type, Allow types are #{valid_ingest_type.join(',')}")
          end

          CSVConfigTree.new(model, ingest_type, attr, children)
        end
      end

      def self.valid_ingest_type
        ["new","update"]
      end

      def header_keys
        attr = []
        if attributes.any?
          attr = attributes.dup
        else
          attr = object_class.constantize.properties.collect{|p| p.first.dup}
        end
        attr = attr.collect{|a| a.prepend(object_class + ".") }
        [[object_class] + attr + children.collect{|c| c.header_keys}].flatten
      end
    end

    class CSVParser
      def self.validate_config (options)
        begin
          CSVConfigTree.new_from_hash(options.fetch(:schema).first)
        rescue StandardError => e
          raise Hyrax::BatchIngest::ReaderError, "Error Parsing Reader Options. Error:" +e.message + " " + e.backtrace.to_s
        end
      end
    end
  end
end
