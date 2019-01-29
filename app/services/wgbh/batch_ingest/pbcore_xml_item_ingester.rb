require 'wgbh/batch_ingest/batch_item_ingester'
require 'wgbh/batch_ingest/pbcore_xml_mapper'
# require 'hyrax/actors/batch_ingest_actor'

module WGBH
  module BatchIngest
    class PBCoreXMLItemIngester < WGBH::BatchIngest::BatchItemIngester

      def ingest
        if batch_item_is_asset?
          batch_item_object = ingest_asset!

          if has_digital_instantiations?
            xml_for_digital_instantiations.each do |xml_for_digital_instantiation|
              ingest_digital_instantiation!(parent_asset: batch_item_object, xml: xml_for_digital_instantiation)
            end
          end

          # if has_physical_instantiations?
          #   xml_for_physical_instantiations.each do |xml_for_physical_instantiation|
          #     ingest_physical_instantiaton!(parent_asset: batch_item_object, xml: xml_for_physical_instantiation)
          #   end
          # end
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

        def has_digital_instantiations?
          pbcore.instantiations.any? { |inst| inst.digital }
        end

        def has_physical_instantiations?
          pbcore.instantiations.any? { |inst| inst.physical }
        end

        def batch_item_is_asset?
          pbcore_xml =~ /pbcoreDescriptionDocument/
        end

        def batch_item_is_digital_instantiation?
          pbcore_xml =~ /pbcoreInstantiationDocument/
        end

        def xml_for_digital_instantiations
          pbcore.instantiations.select { |inst| inst.digital }.map(&:to_xml)
        end

        def ingest_asset!
          asset = Asset.new
          actor = Hyrax::CurationConcern.actor
          env = Hyrax::Actors::Environment.new(asset, current_ability, asset_attrs_from_pbcore)
          actor.create(env)
          asset
        end

        def ingest_digital_instantiation!(parent_asset:, xml:)
          digital_instantiation = DigitalInstantiation.new
          digital_instantiation.skip_file_upload_validation = true
          actor = Hyrax::CurationConcern.actor
          # attrs = WGBH::BatchIngest::PBCoreXMLMapper.new(xml).digital_instantiation_attributes
          env = Hyrax::Actors::Environment.new(digital_instantiation, current_ability, {pbcore_xml: xml})
          actor.create(env)
          parent_asset.members << digital_instantiation
          parent_asset.save!
          digital_instantiation
        end

        def asset_attrs_from_pbcore
          WGBH::BatchIngest::PBCoreXMLMapper.new(pbcore_xml).asset_attributes
        end

        def current_ability
          @current_ability = Ability.new(submitter)
        end

        def pbcore
          @pbcore ||= if batch_item_is_asset?
            PBCore::DescriptionDocument.parse(pbcore_xml)
          elsif batch_item_is_digital_instantiation?
            PBCore::InstantiationDocument.parse(pbcore_xml)
          else
            # TODO: Better error message here?
            raise "Unknown PBCore XML document type"
          end
        end

        def pbcore_xml
          @pbcore_xml ||= if @batch_item.source_data
            @batch_item.source_data
          elsif @batch_item.source_location
            File.read(@batch_item.source_location)
          else
            # TODO: Custom error
            raise "No source data or source location for BatchItem id=#{@batch_item.id}"
          end
        rescue => e
          raise e
        end
    end
  end
end
