# Generated via
#  `rails generate hyrax:work Asset`
class AssetIndexer < AMS::WorkIndexer
  # This indexes the default metadata. You can remove it if you want to
  # provide your own metadata and indexing.
  include Hyrax::IndexesBasicMetadata

  # Fetch remote labels for based_near. You can remove this if you don't want
  # this behavior
  include Hyrax::IndexesLinkedMetadata

  self.thumbnail_path_service = AAPB::AssetThumbnailPathService

  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['date_drsim'] = object.date if object.date
      solr_doc['broadcast_date_drsim'] = object.broadcast_date if object.broadcast_date
      solr_doc['created_date_drsim'] = object.created_date if object.created_date
      solr_doc['copyright_date_drsim'] = object.copyright_date if object.copyright_date
      solr_doc[solr_name('bulkrax_identifier', :facetable)] = object.bulkrax_identifier
      solr_doc['intended_children_count_isi'] = object.intended_children_count.to_i

      if object.admin_data
        # Index the admin_data_gid
        solr_doc['admin_data_tesim'] = object.admin_data.gid if !object.admin_data.gid.blank?
        solr_doc['sonyci_id_ssim'] = object.admin_data.sonyci_id if !object.admin_data.sonyci_id.blank?

        # Programmatically assign annotations by type from controlled vocab
        AnnotationTypesService.new.select_all_options.each do |type|
          # Use the ID defined in the AnnotationType service
          type_id = type[1]
          solr_doc[solr_name(type_id.underscore, :symbol)] = object.try(type_id.to_sym) unless object.try(type_id.to_sym).empty?
        end

        #Indexing for search by batch_id
        solr_doc['hyrax_batch_ingest_batch_id_tesim'] = object.admin_data.hyrax_batch_ingest_batch_id if !object.admin_data.hyrax_batch_ingest_batch_id.blank?
        solr_doc['bulkrax_importer_id_tesim'] = object.admin_data.bulkrax_importer_id if !object.admin_data.bulkrax_importer_id.blank?

        solr_doc['last_pushed'] = object.admin_data.last_pushed if !object.admin_data.last_pushed.blank?
        solr_doc['last_updated'] = object.admin_data.last_updated if !object.admin_data.last_updated.blank?
        solr_doc['needs_update'] = object.admin_data.needs_update if !object.admin_data.needs_update.blank?

      end
    end
  end
end
