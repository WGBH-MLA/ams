# Generated via
#  `rails generate hyrax:work EssenceTrack`
class EssenceTrackIndexer < AMS::WorkIndexer
  # This indexes the default metadata. You can remove it if you want to
  # provide your own metadata and indexing.
  include Hyrax::IndexesBasicMetadata

  # Fetch remote labels for based_near. You can remove this if you don't want
  # this behavior
  include Hyrax::IndexesLinkedMetadata

  self.thumbnail_path_service = AAPB::WorkThumbnailPathService
  # Uncomment this block if you want to add custom indexing behavior:
  def generate_solr_document
   super.tap do |solr_doc|
    solr_doc[solr_name('bulkrax_identifier', :facetable)] = object.bulkrax_identifier
   end
  end
end
