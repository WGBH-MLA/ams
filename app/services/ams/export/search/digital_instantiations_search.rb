module AMS
  module Export
    module Search
      class DigitalInstantiationsSearch < InstantiationsSearch
        private
          def model_class_name
            "DigitalInstantiation"
          end
      end
    end
  end
end
