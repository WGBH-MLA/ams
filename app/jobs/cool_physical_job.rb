require 'aapb/batch_ingest/pbcore_xml_item_ingester'
require 'pbcore'

class CoolPhysicalJob < Hyrax::BatchIngest::BatchItemProcessingJob
  def perform(parent_id:, xml:, batch_item:)
    # we only do physical instantiations round here
    parent = Asset.find(parent_id)
    physical_inst = AAPB::BatchIngest::PBCoreXMLItemIngester.new(batch_item, {}).ingest_physical_instantiation!(parent: parent, xml: xml)
    pbcore_physical = PBCore::Instantiation.parse(xml)
    # fire these off while we have em
    pbcore_physical.essence_tracks.each do |ess_track|
      CoolEssenceJob.perform_later(parent_id: physical_inst.id, xml: ess_track.to_xml, batch_item: batch_item)
    end
    # Need to set @work to the ingested PhysicalInstantiation in order for
    # the `after_perform` hook of Hyrax::BatchIngest::BatchItemProcessingJob
    # to properly set BatchItem#repo_object_id. If that sounds a bit convoluted
    # it's because it is.
    @work = physical_inst
  end
end
