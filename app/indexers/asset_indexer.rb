# Generated via
#  `rails generate hyrax:work Asset`
class AssetIndexer < AMS::WorkIndexer
  # This indexes the default metadata. You can remove it if you want to
  # provide your own metadata and indexing.
  include Hyrax::IndexesBasicMetadata

  # Fetch remote labels for based_near. You can remove this if you don't want
  # this behavior
  include Hyrax::IndexesLinkedMetadata

  self.thumbnail_path_service = WGBH::WorkThumbnailPathService

  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['date_drsim'] = object.date if object.date
      solr_doc['broadcast_date_drsim'] = object.broadcast_date if object.broadcast_date
      solr_doc['created_date_drsim'] = object.created_date if object.created_date
      solr_doc['copyright_date_drsim'] = object.copyright_date if object.copyright_date
      if object.admin_data
        #Indexing as english text so we can use it on asset show page
        solr_doc['admin_data_tesim'] = object.admin_data.gid if !object.admin_data.gid.blank?
        solr_doc['level_of_user_access_ssim'] = solr_doc['level_of_user_access_tesim'] = object.admin_data.level_of_user_access if !object.admin_data.level_of_user_access.blank?
        solr_doc['minimally_cataloged_ssim'] = solr_doc['minimally_cataloged_tesim'] = object.admin_data.minimally_cataloged if !object.admin_data.minimally_cataloged.to_s.blank?
        solr_doc['outside_url_ssim'] = solr_doc['outside_url_tesim'] = object.admin_data.outside_url if !object.admin_data.outside_url.blank?
        solr_doc['special_collection_ssim'] = solr_doc['special_collection_tesim'] = object.admin_data.special_collection if object.admin_data.special_collection.any?(&:present?)
        solr_doc['transcript_status_ssim'] = solr_doc['transcript_status_tesim'] = object.admin_data.transcript_status if !object.admin_data.transcript_status.blank?
        solr_doc['sonyci_id_ssim'] = solr_doc['sonyci_id_tesim'] = object.admin_data.sonyci_id if object.admin_data.sonyci_id.any?(&:present?)
        solr_doc['licensing_info_ssim'] = solr_doc['licensing_info_tesim'] = object.admin_data.licensing_info if !object.admin_data.licensing_info.blank?

        #Indexing for Facets
        solr_doc['level_of_user_access_ssim'] =  object.admin_data.level_of_user_access if !object.admin_data.level_of_user_access.blank?
        solr_doc['minimally_cataloged_ssim'] =  object.admin_data.minimally_cataloged if !object.admin_data.minimally_cataloged.to_s.blank?
        solr_doc['outside_url_ssim']  = object.admin_data.outside_url if !object.admin_data.outside_url.blank?
        solr_doc['special_collection_ssim'] = object.admin_data.special_collection if object.admin_data.special_collection.any?(&:present?)
        solr_doc['transcript_status_ssim'] = object.admin_data.transcript_status if !object.admin_data.transcript_status.blank?
        solr_doc['sonyci_id_ssim'] = object.admin_data.sonyci_id if object.admin_data.sonyci_id.any?(&:present?)
        solr_doc['licensing_info_ssim'] = object.admin_data.licensing_info if !object.admin_data.licensing_info.blank?
      end
    end
  end
end

