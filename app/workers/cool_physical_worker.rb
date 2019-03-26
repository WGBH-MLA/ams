require 'aapb/batch_ingest/batch_item_ingester'
require 'aapb/batch_ingest/pbcore_xml_mapper'
require 'aapb/batch_ingest/pbcore_xml_item_ingester'

class CoolPhysicalWorker
  include Sidekiq::Worker
  include AAPB::BatchIngest

  def perform(parent_id, pbcore_physical_xml, batch_item_json)
    # we only do physical instantiations round here
    batch_item = Hyrax::BatchIngest::BatchItem.new(JSON.parse(batch_item_json))
    parent = Asset.find(parent_id)
    physical_inst = AAPB::BatchIngest::PBCoreXMLItemIngester.new(batch_item, {}).ingest_physical_instantiation!(parent: parent, xml: pbcore_physical_xml)

    # fire these off while we have em
    physical_inst.essence_tracks.each do |ess_track|
      CoolEssenceWorker.perform_async(physical_inst.id, ess_track.to_xml, batch_item_json)
    end

  end
end