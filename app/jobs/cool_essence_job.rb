require 'aapb/batch_ingest/pbcore_xml_item_ingester'

class CoolEssenceJob < ApplicationJob
  def perform(parent_id, pbcore_essence_xml, batch_item)
    # we only do essoes round here
    parent = ActiveFedora::Base.find(parent_id)
    AAPB::BatchIngest::PBCoreXMLItemIngester.new(batch_item, {}).ingest_essence_track!(parent: parent, xml: pbcore_essence_xml)
  end
end
