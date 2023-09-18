module AMS
  module Export
    module Search
      class PhysicalInstantiationsSearch < InstantiationsSearch
        private
          def model_class_name
            "PhysicalInstantiationResource"
          end
      end
    end
  end
end
