# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource EssenceTrackResource`
class EssenceTrackResourceIndexer < AMS::ValkyrieWorkIndexer
  include Hyrax::Indexer(:basic_metadata)
  include Hyrax::Indexer(:essence_track_resource)

  self.thumbnail_path_service = AAPB::WorkThumbnailPathService

  # Uncomment this block if you want to add custom indexing behavior:
  def to_solr
    super.tap do |index_document|
      index_document['bulkrax_identifier_sim'] = resource.bulkrax_identifier
    end
  end
end
