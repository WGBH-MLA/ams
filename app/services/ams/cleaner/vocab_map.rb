require 'yaml'

module AMS
  module Cleaner
    module VocabMap
      class << self

        def for_pbcore_element(pbcore_element)
          YAML.load_file(Rails.root + "config/pbcore_cleaner_config.yml").fetch(pbcore_element_key(pbcore_element), nil)
        end

        def for_pbcore_class(pbcore_class)
          YAML.load_file(Rails.root + "config/pbcore_cleaner_config.yml").fetch(pbcore_class_key(pbcore_class), nil)
        end

        private

        def pbcore_element_key(pbcore_element)
          pbcore_element.class.name.split('::').last.underscore
        end

        def pbcore_class_key(pbcore_class)
          pbcore_class.to_s.split('::').last.underscore
        end

      end
    end
  end
end
