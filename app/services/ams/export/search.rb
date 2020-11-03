require 'ams/export/search/base'
require 'ams/export/search/assets_search'
require 'ams/export/search/digital_instantiations_search'
require 'ams/export/search/physical_instantiations_search'

module AMS
  module Export
    module Search
      class << self
        def for_export_type(export_type)
          {
            'asset' => AssetsSearch,
            'pbcore_zip' => AssetsSearch,
            'push_to_aapb' => AssetsSearch,
            'digital_instantiation' => DigitalInstantiationsSearch,
            'physical_instantiation' => PhysicalInstantiationsSearch
          }[export_type]
        end
      end
    end
  end
end
