require 'ams/export/results/base'
require 'ams/export/results/assets_csv_results'
require 'ams/export/results/pbcore_zip_results'
require 'ams/export/results/digital_instantiations_csv_results'
require 'ams/export/results/physical_instantiations_csv_results'

module AMS
  module Export
    module Results
      def self.for_export_type(export_type)
        {
          asset: AssetsCSVResults,
          pbcore_zip: PBCoreZipResults,
          push_to_aapb: PBCoreZipResults,
          digital_instantiation: DigitalInstantiationsCSVResults,
          physical_instantiation: PhysicalInstantiationsCSVResults
        }.fetch(export_type.to_sym)
      end
    end
  end
end
