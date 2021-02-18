require 'ams/migrations/audit/ams1_asset'

module AMS
  module Migrations
    module Audit
      class AuditingService

        attr_reader :asset_ids

        def initialize(asset_ids: [])
          @asset_ids = Array(asset_ids)
        end

        def report
          @report ||= build_report
        end

        private

        def ams_comparisons
          @ams_comparisons ||= asset_ids.map{ |id| AMSComparison.new(id) }
        end

        def build_report
          { "matches" => matches.map(&:report), "mismatches" => mismatches.map(&:report), "errors" => errors.map(&:report) }
        end

        def matches
          @matches ||= ams_comparisons.select{ |comp| comp.assets_found? && comp.assets_match? }
        end

        def mismatches
          @mismatches ||= ams_comparisons.select{ |comp| comp.assets_found? && !comp.assets_match? }
        end

        def errors
          @errors || ams_comparisons.select{ |comp| !comp.assets_found? }
        end
      end
    end
  end
end