module AMS
  module Cleaner
    class PBCoreElementEditor

      attr_reader :element

      def initialize(element:)
        @element = element
      end

      def value
        set_value
      end

      def type
        set_type
      end

      def vocab_map
        @vocab_map ||= VocabMap.for_pbcore_element(element)
      end

      private

      def set_value
        return element.value if ( vocab_map.nil? || map_values.nil? )
        # Set to empty string to get default for an empty string in config file
        element.value = '' if element.value.nil?
        map_value
      end

      def set_type
        return element.type if ( vocab_map.nil? || map_types.nil? )
        # Set to empty string to get default for an empty string in config file
        element.type = '' if element.type.nil?
        map_type
      end

      def map_values
        @map_values ||= vocab_map.fetch("values", nil)
      end

      def map_types
        @map_types ||= vocab_map.fetch("types", nil)
      end

      def map_value
        map_values.select{ |key| element.value.downcase.include? key.downcase }.values.first || raise("No match found for '#{element.value}' in VocabMap")
      end

      def map_type
        map_types.select{ |key| element.type.downcase.include? key.downcase }.values.first || raise("No match found for '#{element.type}' in VocabMap")
      end

    end
  end
end