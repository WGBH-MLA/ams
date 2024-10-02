# Generated via
#  `rails generate hyrax:work PhysicalInstantiation`
class PhysicalInstantiationIndexer < AMS::WorkIndexer
  # This indexes the default metadata. You can remove it if you want to
  # provide your own metadata and indexing.
  include Hyrax::IndexesBasicMetadata

  # Fetch remote labels for based_near. You can remove this if you don't want
  # this behavior
  include Hyrax::IndexesLinkedMetadata

  self.thumbnail_path_service = AAPB::WorkThumbnailPathService

  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc[solr_name('bulkrax_identifier', :facetable)] = object.bulkrax_identifier
      if object.instantiation_admin_data
        #Indexing as english text so we can use it on asset show page
        solr_doc['instantiation_admin_data_tesim'] = object.instantiation_admin_data.gid if !object.instantiation_admin_data.gid.blank?
        solr_doc['aapb_preservation_lto_ssim'] = solr_doc['aapb_preservation_lto_tesim'] = object.instantiation_admin_data.aapb_preservation_lto if !object.instantiation_admin_data.aapb_preservation_lto.blank?
        solr_doc['aapb_preservation_disk_ssim'] = solr_doc['aapb_preservation_disk_tesim'] = object.instantiation_admin_data.aapb_preservation_disk if !object.instantiation_admin_data.aapb_preservation_disk.blank?
      end
    end
  end
end
