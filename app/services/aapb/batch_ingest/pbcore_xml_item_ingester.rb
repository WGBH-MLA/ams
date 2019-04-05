require 'aapb/batch_ingest/batch_item_ingester'
require 'aapb/batch_ingest/pbcore_xml_mapper'

module AAPB
  module BatchIngest
    class PBCoreXMLItemIngester < AAPB::BatchIngest::BatchItemIngester

      def ingest
        if batch_item_is_asset?
          batch_item_object = ingest_asset!

          pbcore_digital_instantiations.each do |pbcore_digital_instantiation|
            ingest_digital_instantiation!(parent: batch_item_object, xml: pbcore_digital_instantiation.to_xml)
          end

          pbcore_physical_instantiations.each do |pbcore_physical_instantiation|
            physical_instantiation = ingest_physical_instantiation!(parent: batch_item_object, xml: pbcore_physical_instantiation.to_xml)
            pbcore_physical_instantiation.essence_tracks.each do |pbcore_essence_track|
              ingest_essence_track!(parent: physical_instantiation, xml: pbcore_essence_track.to_xml)
            end
          end
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

        def pbcore_digital_instantiations
          pbcore.instantiations.select { |inst| inst.digital }
        end

        def pbcore_physical_instantiations
          pbcore.instantiations.select { |inst| inst.physical }
        end

        def ingest_asset!
          asset = Asset.new
          actor = Hyrax::CurationConcern.actor
          attrs = AAPB::BatchIngest::PBCoreXMLMapper.new(pbcore_xml).asset_attributes
          attrs[:hyrax_batch_ingest_batch_id] = batch_id
          env = Hyrax::Actors::Environment.new(asset, current_ability, attrs)
          actor.create(env)
          asset
        end

        def ingest_digital_instantiation!(parent:, xml:)
          digital_instantiation = DigitalInstantiation.new
          digital_instantiation.skip_file_upload_validation = true
          actor = Hyrax::CurationConcern.actor
          attrs = {
            pbcore_xml: xml,
            in_works_ids: [parent.id]
          }
          env = Hyrax::Actors::Environment.new(digital_instantiation, current_ability, attrs)
          actor.create(env)
          # reload the parent so that the children show up in the .members
          # accessor
          parent.reload
          digital_instantiation
        end

        def ingest_physical_instantiation!(parent:, xml:)
          physical_instantiation = PhysicalInstantiation.new
          actor = Hyrax::CurationConcern.actor
          attrs = AAPB::BatchIngest::PBCoreXMLMapper.new(xml).physical_instantiation_attributes
          attrs[:in_works_ids] = [parent.id]
          env = Hyrax::Actors::Environment.new(physical_instantiation, current_ability, attrs)
          actor.create(env)
          # reload the parent so that the children show up in the .members
          # accessor
          parent.reload
          physical_instantiation
        end

        def ingest_essence_track!(parent:, xml:)
          essence_track = EssenceTrack.new
          actor = Hyrax::CurationConcern.actor
          attrs = AAPB::BatchIngest::PBCoreXMLMapper.new(xml).essence_track_attributes
          attrs[:in_works_ids] = [parent.id]
          env = Hyrax::Actors::Environment.new(essence_track, current_ability, attrs)
          actor.create(env)
          parent.reload
          essence_track
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
