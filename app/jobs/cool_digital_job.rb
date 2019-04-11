require 'aapb/batch_ingest/pbcore_xml_item_ingester'

class CoolDigitalJob < ApplicationJob
  def perform(parent_id, pbcore_digital_xml, batch_item)
    # we only do digi instantiations round here
    parent = Asset.find(parent_id)
    AAPB::BatchIngest::PBCoreXMLItemIngester.new(batch_item, {}).ingest_digital_instantiation!(parent: parent, xml: pbcore_digital_xml)
  end
end
