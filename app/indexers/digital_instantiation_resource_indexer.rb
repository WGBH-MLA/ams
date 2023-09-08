# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource DigitalInstantiationResource`
class DigitalInstantiationResourceIndexer < Hyrax::ValkyrieWorkIndexer
  include Hyrax::Indexer(:basic_metadata)
  include Hyrax::Indexer(:digital_instantiation_resource)

  self.thumbnail_path_service = AAPB::WorkThumbnailPathService

  # Uncomment this block if you want to add custom indexing behavior:
  def to_solr
    super.tap do |index_document|
      index_document['bulkrax_identifier_sim'] = resource.bulkrax_identifier
      if resource.instantiation_admin_data
        #Indexing as english text so we can use it on asset show page
        index_document['instantiation_admin_data_tesim'] = resource.instantiation_admin_data.gid if !resource.instantiation_admin_data.gid.blank?
        index_document['aapb_preservation_lto_ssim'] = index_document['aapb_preservation_lto_tesim'] = resource.instantiation_admin_data.aapb_preservation_lto if !resource.instantiation_admin_data.aapb_preservation_lto.blank?
        index_document['aapb_preservation_disk_ssim'] = index_document['aapb_preservation_disk_tesim'] = resource.instantiation_admin_data.aapb_preservation_disk if !resource.instantiation_admin_data.aapb_preservation_disk.blank?
        index_document['md5_ssim'] = resource.instantiation_admin_data.md5 if !resource.instantiation_admin_data.md5.blank?
      end
    end
  end
end
