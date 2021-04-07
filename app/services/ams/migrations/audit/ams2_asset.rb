module AMS
  module Migrations
    module Audit
      class AMS2Asset
        attr_reader :solr_document

        def initialize(solr_document:)
          raise 'AMS2Asset must be initialized with a SolrDocument' unless solr_document.class == SolrDocument
          @solr_document = solr_document
        end

        def digital_instantiations_count
          @digital_instantiations_count ||= solr_document.present? ? asset_members.select{ |mem| mem["has_model_ssim"].include?("DigitalInstantiation") }.count : nil
        end

        def physical_instantiations_count
          @physical_instantiations_count ||= solr_document.present? ? asset_members.select{ |mem| mem["has_model_ssim"].include?("PhysicalInstantiation") }.count : nil
        end

        def essence_tracks_count
          @essence_tracks_count ||= solr_document.present? ? asset_members.select{ |mem| mem["has_model_ssim"].include?("EssenceTrack") }.count : nil
        end

        private

        def asset_members
          @asset_members ||= SolrDocument.get_members(solr_document["id"]).map{ |id| SolrDocument.find(id)}
        end
      end
    end
  end
end