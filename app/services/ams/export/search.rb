require 'ams/export/search/base'
require 'ams/export/search/catalog_search'
require 'ams/export/search/digital_instantiations_search'
require 'ams/export/search/physical_instantiations_search'

module AMS
  module Export
    module Search
      class << self
        def for_export_type(export_type)
          {
            asset: CatalogSearch,
            pbcore_zip: CatalogSearch,
            digital_instantiation: DigitalInstantiationsSearch,
            physical_instantiation: PhysicalInstantiationsSearch
          }.fetch(export_type.to_sym)
        end
      end
    end
  end
end
