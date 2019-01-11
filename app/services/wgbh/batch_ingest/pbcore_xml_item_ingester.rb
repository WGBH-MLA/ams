require 'wgbh/batch_ingest/batch_item_ingester'
require 'wgbh/batch_ingest/pbcore_xml_mapper'
# require 'hyrax/actors/batch_ingest_actor'

module WGBH
  module BatchIngest
    class PBCoreXMLItemIngester < WGBH::BatchIngest::BatchItemIngester

      def ingest
        if batch_item_is_asset?
          batch_item_object = ingest_asset!
        elsif batch_item_is_digital_instantiation?
          # TODO: implement digital instantiation ingest.
          raise "DigitalInstantiation ingest not implemented yet!"
        else
          # TODO: More specific error?
          raise "PBCore XML ingest does not know how to ingest the given XML"
        end

        batch_item_object
      end

      private

        def batch_item_is_asset?
          pbcore_xml =~ /pbcoreDescriptionDocument/
        end

        def batch_item_is_digital_instantiation?
          pbcore_xml =~ /pbcoreInstantiationDocument/
        end

        def ingest_asset!
          asset = Asset.new
          actor = Hyrax::CurationConcern.actor
          env = Hyrax::Actors::Environment.new(asset, current_ability, asset_attrs_from_pbcore)
          actor.create(env)
          asset
        end

        def asset_attrs_from_pbcore
          WGBH::BatchIngest::PBCoreXMLMapper.new(pbcore_xml).asset_attributes
        end

        def current_ability
          @current_ability = Ability.new(submitter)
        end

        def pbcore_xml
          @pbcore_xml ||= File.read(@batch_item.source_location)
        end
    end
  end
end
