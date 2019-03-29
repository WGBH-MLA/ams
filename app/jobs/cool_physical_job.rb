require 'aapb/batch_ingest/pbcore_xml_item_ingester'
require 'pbcore'

class CoolPhysicalJob < ApplicationJob
  def perform(parent_id, pbcore_physical_xml, batch_item)
    # we only do physical instantiations round here
    parent = Asset.find(parent_id)
    physical_inst = AAPB::BatchIngest::PBCoreXMLItemIngester.new(batch_item, {}).ingest_physical_instantiation!(parent: parent, xml: pbcore_physical_xml)
    pbcore_physical = PBCore::Instantiation.parse(pbcore_physical_xml)
    # fire these off while we have em
    pbcore_physical.essence_tracks.each do |ess_track|
      CoolEssenceJob.perform_later(physical_inst.id, ess_track.to_xml, batch_item)
    end
  end
end
