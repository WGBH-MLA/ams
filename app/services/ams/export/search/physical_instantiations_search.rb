module AMS
  module Export
    module Search
      class PhysicalInstantiationsSearch < InstantiationsSearch
        private
          def model_class_name
            "PhysicalInstantiation"
          end
      end
    end
  end
end
