require 'aapb/batch_ingest/batch_item_ingester'
require 'aapb/batch_ingest/pbcore_xml_mapper'
require 'aapb/batch_ingest/pbcore_xml_item_ingester'

class CoolWorker
  include Sidekiq::Worker
  include AAPB::BatchIngest

  def perform(parent_id, pbcore_digital_xml, batch_item_json)
    # we only do digi instantiations round here
    batch_item = Hyrax::BatchIngest::BatchItem.new(JSON.parse(batch_item_json))
    parent = Asset.find(parent_id)
    AAPB::BatchIngest::PBCoreXMLItemIngester.new(batch_item, {}).ingest_digital_instantiation!(parent: parent, xml: pbcore_digital_xml)
  end
end