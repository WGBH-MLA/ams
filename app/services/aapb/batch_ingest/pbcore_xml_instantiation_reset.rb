require 'aapb/batch_ingest/batch_item_ingester'
require 'aapb/batch_ingest/pbcore_xml_mapper'
require 'aapb/batch_ingest/zipped_pbcore_digital_instantiation_mapper'
require 'aapb/batch_ingest/errors'
require 'aapb/batch_ingest/pbcore_xml_ingester_behavior'

module AAPB
  module BatchIngest
    class PBCoreXMLInstantiationReset < AAPB::BatchIngest::BatchItemIngester

      include AAPB::BatchIngest::PBCoreXMLIngesterBehavior

      attr_reader :asset_resource_id

      def ingest
        # Do not proceed unless submitter has proper permissions
        confirm_submitter_permissions!

        # This is a bit of a workaround. Errors will be raised from deep within
        # the stack if the user cannot be converted to a Sipity::Entity.
        raise "Could not find or create Sipity Agent for user #{submitter}" unless sipity_agent

        remove_all_instantiations!

        pbcore_digital_instantiations.each do |pbcore_digital_instantiation|
          di_batch_item = Hyrax::BatchIngest::BatchItem.create!(batch: batch_item.batch, status: 'initialized', id_within_batch: batch_item.id_within_batch)
          CoolDigitalJob.perform_later(parent_id: asset_resource.id.to_s, xml: pbcore_digital_instantiation.to_xml, batch_item: di_batch_item)
        end

        pbcore_physical_instantiations.each do |pbcore_physical_instantiation|
          pi_batch_item = Hyrax::BatchIngest::BatchItem.create!(batch: batch_item.batch, status: 'initialized', id_within_batch: batch_item.id_within_batch)
          CoolPhysicalJob.perform_later(parent_id: asset_resource.id.to_s, xml: pbcore_physical_instantiation.to_xml, batch_item: pi_batch_item)
        end

        asset_resource
      end

      private

        def remove_all_instantiations!
          instantiations = asset_resource.digital_instantiation_resources + asset_resource.physical_instantiation_resources
          instantiations.each do |inst|
            begin
              Hyrax.persister.delete(resource: inst)
              Hyrax.index_adapter.delete(resource: inst)
            rescue => e
              log.error("#{e.class}: #{e.message}")
              log.debug(e.backtrace.join("\n"))
            end
          end
          Hyrax.index_adapter.save(resource: asset_resource)
        end

        def log
          @log ||= Logger.new(STDOUT)
        end

        def asset_resource
          @asset_resource ||= AssetResource.find(asset_resource_id)
        end

        def asset_resource_id
          pbcore.identifiers.detect{|id| id.source == 'http://americanarchiveinventory.org' }&.value.gsub('/', '-')
        end
    end
  end
end
