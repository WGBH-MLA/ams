# Generated via
#  `rails generate hyrax:work Asset`
class AssetIndexer < Hyrax::WorkIndexer
  # This indexes the default metadata. You can remove it if you want to
  # provide your own metadata and indexing.
  include Hyrax::IndexesBasicMetadata

  # Fetch remote labels for based_near. You can remove this if you don't want
  # this behavior
  include Hyrax::IndexesLinkedMetadata

  self.thumbnail_path_service = WGBH::WorkThumbnailPathService

  def generate_solr_document
    if object.admin_data
      super.tap do |solr_doc|
        solr_doc['admin_data_tesim'] = object.admin_data.gid
        solr_doc['level_of_user_access_tesim'] = object.admin_data.level_of_user_access
        solr_doc['minimally_cataloged_tesim'] = object.admin_data.minimally_cataloged.to_s
        solr_doc['outside_url_tesim'] = object.admin_data.outside_url
        solr_doc['special_collection_tesim'] = object.admin_data.special_collection
        solr_doc['transcript_status_tesim'] = object.admin_data.transcript_status
        solr_doc['sonyci_id_tesim'] = object.admin_data.sonyci_id
        solr_doc['licensing_info_tesim'] = object.admin_data.licensing_info
      end
    end
  end
end
