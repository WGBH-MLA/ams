require 'ams/migrations/audit/ams1_asset'

module AMS
  module Migrations
    module Audit
      class AuditingService

        attr_reader :asset_ids, :user

        def initialize(asset_ids: [], user:)
          @asset_ids = Array(asset_ids)
          @user = user
        end

        def report
          @report ||= build_report
        end

        private

        def ams_comparisons
          @ams_comparisons ||= found_ids.map{ |id| AMSComparison.new(
            ams1_asset: ams1_assets.find{ |asset| id == asset.id },
            ams2_asset: ams2_assets.find{ |asset| id == asset.solr_document["id"] }
          ) }
        end

        def ams1_assets
          @ams1_assets ||= asset_ids.map{ |id| AMS1Asset.new(id: id) }
        end

        def ams2_assets
          @ams2_assets ||= ams2_solr_documents.map{ |doc| AMS2Asset.new(solr_document: doc) }
        end

        def ams2_solr_documents
          @ams2_solr_docs ||= AMS::Export::Search::CombinedIDSearch.new(ids: asset_ids, user: user, model_class_name: 'Asset').solr_documents
        end

        def found_ids
          asset_ids.select{ |id| !asset_ids_not_found.include?(id) }
        end

        def asset_ids_not_found
          @asset_ids_not_found ||= (ams1_asset_ids_not_found + ams2_asset_ids_not_found).uniq
        end

        def ams1_asset_ids_not_found
          @ams1_asset_ids_not_found ||= ams1_assets.select{ |asset| asset.pbcore.nil? }.map(&:id)
        end

        def ams2_asset_ids_not_found
          asset_ids.select{ |id| !ams2_solr_documents.map{ |doc| doc["id"] }.include?(id) }
        end

        def build_report
          { "matches" => matches.map(&:report), "mismatches" => mismatches.map(&:report) , "errors" => errors }
        end

        def matches
          ams_comparisons.select{ |comp| comp.assets_match? }
        end

        def mismatches
          ams_comparisons.select{ |comp| !comp.assets_match? }
        end

        def errors
          asset_ids_not_found.map{ |id| error_report(id) }
        end

        def error_report(id)
          { "id" => id,
            "ams1" => {
              "pbcore_not_found?" => ams1_asset_ids_not_found.include?(id) },
            "ams2" => {
              "solr_document_not_found?" => ams2_asset_ids_not_found.include?(id) }
          }
        end
      end
    end
  end
end