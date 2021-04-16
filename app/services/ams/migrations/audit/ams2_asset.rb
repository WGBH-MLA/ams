module AMS
  module Migrations
    module Audit
      class AMS2Asset
        attr_reader :solr_document

        def initialize(solr_document:)
          raise ArgumentError, "AMS2Asset expects a SolrDocument but #{solr_document.class} was given" unless solr_document.is_a? SolrDocument
          @solr_document = solr_document
        end

        def digital_instantiations_count
          solr_document.all_members(only: 'DigitalInstantiation').count
        end

        def physical_instantiations_count
          solr_document.all_members(only: 'PhysicalInstantiation').count
        end

        def essence_tracks_count
          solr_document.all_members(only: 'EssenceTrack').count
        end

        private

        def asset_members
          @asset_members ||= SolrDocument.get_members(solr_document["id"])
        end
      end
    end
  end
end
