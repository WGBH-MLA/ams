require 'aapb/batch_ingest/batch_item_ingester'
require 'aapb/batch_ingest/pbcore_xml_mapper'
require 'aapb/batch_ingest/pbcore_xml_item_ingester'
require 'pbcore'

class CoolPhysicalWorker
  include Sidekiq::Worker
  include AAPB::BatchIngest
  include PBCore

  def perform(parent_id, pbcore_physical_xml, batch_item_json)
    # we only do physical instantiations round here
    batch_item = Hyrax::BatchIngest::BatchItem.new(JSON.parse(batch_item_json))
    parent = Asset.find(parent_id)
    fedora_physical_inst = AAPB::BatchIngest::PBCoreXMLItemIngester.new(batch_item, {}).ingest_physical_instantiation!(parent: parent, xml: pbcore_physical_xml)

    pbcore_physical = PBCore::Instantiation.parse(pbcore_physical_xml)

    # fire these off while we have em
    pbcore_physical.essence_tracks.each do |ess_track|
      CoolEssenceWorker.perform_async(fedora_physical_inst.id, ess_track.to_xml, batch_item_json, 'physical')
    end
  end
end