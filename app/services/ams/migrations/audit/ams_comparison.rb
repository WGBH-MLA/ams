require 'pbcore'

module AMS
  module Migrations
    module Audit
      class AMSComparison
        attr_reader :id

        def initialize(id)
          @id = id
        end

        def report
          @report ||= assets_found? ? asset_report : error_report
        end

        def assets_found?
          ams1_asset.pbcore_present? && ams2_asset.solr_document_present?
        end

        def assets_match?
          digital_instantiations_match? && physical_instantiations_match? && essence_tracks_match?
        end

        private

        def ams1_asset
          @ams1_asset ||= AMS1Asset.new(id)
        end

        def ams2_asset
          @ams2_asset ||= AMS2Asset.new(id)
        end

        def digital_instantiations_match?
          ams1_asset.digital_instantiations_count == ams2_asset.digital_instantiations_count
        end

        def physical_instantiations_match?
          ams1_asset.physical_instantiations_count == ams2_asset.physical_instantiations_count
        end

        def essence_tracks_match?
          ams1_asset.essence_tracks_count == ams2_asset.essence_tracks_count
        end

        def asset_report
          { "ams1" => {
              "digital_instantiations" => ams1_asset.digital_instantiations_count,
              "physical_instantiations" => ams1_asset.physical_instantiations_count,
              "essence_tracks" => ams1_asset.essence_tracks_count },
            "ams2" => {
              "digital_instantiations" => ams2_asset.digital_instantiations_count,
              "physical_instantiations" => ams2_asset.physical_instantiations_count,
              "essence_tracks" => ams2_asset.essence_tracks_count }
          }
        end

        def error_report
          { "ams1" => {
              "pbcore_present?" => ams1_asset.pbcore_present? },
            "ams2" => {
              "solr_document_present?" => ams2_asset.solr_document_present? }
          }
        end

      end
    end
  end
end
