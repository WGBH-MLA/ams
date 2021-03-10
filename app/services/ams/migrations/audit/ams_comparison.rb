require 'pbcore'

module AMS
  module Migrations
    module Audit
      class AMSComparison
        attr_reader :ams1_asset, :ams2_asset, :id

        def initialize(ams1_asset:, ams2_asset:)
          raise 'AMSComparison must be initialized with an AMS1Asset and AMS2Asset' unless ams1_asset.class == AMS1Asset && ams2_asset.class == AMS2Asset
          @ams1_asset = ams1_asset
          @ams2_asset = ams2_asset
          @id = confirm_asset_id
        end

        def report
          @report ||= ams1_asset.pbcore.present? ? asset_report : error_report
        end

        def assets_match?
          digital_instantiations_match? && physical_instantiations_match? && essence_tracks_match?
        end

        private

        def confirm_asset_id
          raise 'AMS1Asset and AMS2Asset IDs must match. AMS1Asset: #{ams1_asset.id} | AMS2Asset: #{ams2_asset.solr_document[\'id\']}' unless ams1_asset.id == ams2_asset.solr_document['id']
          ams1_asset.id
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
          {
            "id" => id,
            "ams1" => {
              "digital_instantiations" => ams1_asset.digital_instantiations_count,
              "physical_instantiations" => ams1_asset.physical_instantiations_count,
              "essence_tracks" => ams1_asset.essence_tracks_count },
            "ams2" => {
              "digital_instantiations" => ams2_asset.digital_instantiations_count,
              "physical_instantiations" => ams2_asset.physical_instantiations_count,
              "essence_tracks" => ams2_asset.essence_tracks_count }
          }
        end

        # Probably need to move to the Service since we'll be building all the AMS1Assets and AMS2Assets there
        # def error_report
        #   { "id" => id,
        #     "ams1" => {
        #       "pbcore_present?" => ams1_asset.pbcore_present? },
        #     "ams2" => {
        #       "solr_document_present?" => ams2_asset.solr_document_present? }
        #   }
        # end

      end
    end
  end
end
