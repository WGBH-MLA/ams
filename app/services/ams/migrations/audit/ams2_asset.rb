module AMS
  module Migrations
    module Audit
      class AMS2Asset
        attr_reader :id

        def initialize(id)
          @id = id
        end

        def solr_document
          @solr_document ||= find_solr_doc
        end

        def solr_document_present?
          solr_document.present?
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

        def find_solr_doc
          SolrDocument.find id
        rescue Blacklight::Exceptions::RecordNotFound
          nil
        end

        def asset_members
          @asset_members ||= solr_document.all_nested_member_ids.map{ |id| SolrDocument.find(id)}
        end
      end
    end
  end
end