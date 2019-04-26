require 'aapb/batch_ingest/pbcore_xml_item_ingester'

class CoolEssenceJob < Hyrax::BatchIngest::BatchItemProcessingJob
  def perform(parent_id:, xml:, batch_item:)
    # we only do essoes round here
    parent = ActiveFedora::Base.find(parent_id)
    # Need to set @work to the ingested EssenceTrack in order for
    # the `after_perform` hook of Hyrax::BatchIngest::BatchItemProcessingJob
    # to properly set BatchItem#repo_object_id. If that sounds a bit convoluted
    # it's because it is.
    @work = AAPB::BatchIngest::PBCoreXMLItemIngester.new(batch_item, {}).ingest_essence_track!(parent: parent, xml: xml)
  end
end
