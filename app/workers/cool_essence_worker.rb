require 'aapb/batch_ingest/batch_item_ingester'
require 'aapb/batch_ingest/pbcore_xml_mapper'
require 'aapb/batch_ingest/pbcore_xml_item_ingester'

class CoolEssenceWorker
  include Sidekiq::Worker
  include AAPB::BatchIngest

  def perform(parent_id, pbcore_essence_xml, batch_item_json)
    # we only do essies round here bruh
    batch_item = Hyrax::BatchIngest::BatchItem.new(JSON.parse(batch_item_json))
    parent = PhysicalInstantiation.find(parent_id)
    AAPB::BatchIngest::PBCoreXMLItemIngester.new(batch_item, {}).ingest_essence_track!(parent: parent, xml: pbcore_essence_xml)
  end
end