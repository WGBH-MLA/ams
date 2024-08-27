# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource AssetResource`
class AssetResourceIndexer < AMS::ValkyrieWorkIndexer
  include Hyrax::Indexer(:basic_metadata)
  include Hyrax::Indexer(:asset_resource)

  self.thumbnail_path_service = AAPB::AssetThumbnailPathService

  # Uncomment this block if you want to add custom indexing behavior:
  def to_solr
    super.tap do |index_document|
      index_document['date_drsim'] = resource.date if resource.date
      index_document['broadcast_date_drsim'] = resource.broadcast_date if resource.broadcast_date
      index_document['created_date_drsim'] = resource.created_date if resource.created_date
      index_document['copyright_date_drsim'] = resource.copyright_date if resource.copyright_date
      index_document['bulkrax_identifier_sim'] = resource.bulkrax_identifier
      index_document['intended_children_count_isi'] = resource.intended_children_count.to_i

      if resource.admin_data
        # Index the admin_data_gid
        index_document['admin_data_tesim'] = resource.admin_data.gid if !resource.admin_data.gid.blank?
        index_document['admin_data_gid_ssim'] = resource.admin_data.gid if !resource.admin_data.gid.blank?
        index_document['sonyci_id_ssim'] = resource.admin_data.sonyci_id if !resource.admin_data.sonyci_id.blank?

        # Programmatically assign annotations by type from controlled vocab
        AnnotationTypesService.new.select_all_options.each do |type|
          # Use the ID defined in the AnnotationType service
          type_id = type[1]
          unless resource.try(type_id.to_sym).nil? || resource.try(type_id.to_sym).blank?
            index_document ["#{type_id.underscore}_ssim"] = resource.try(type_id.to_sym)
        end

        #Indexing for search by batch_id
        index_document['hyrax_batch_ingest_batch_id_tesim'] = resource.admin_data.hyrax_batch_ingest_batch_id if !resource.admin_data.hyrax_batch_ingest_batch_id.blank?
        index_document['bulkrax_importer_id_tesim'] = resource.admin_data.bulkrax_importer_id if !resource.admin_data.bulkrax_importer_id.blank?

        index_document['last_pushed'] = resource.admin_data.last_pushed if !resource.admin_data.last_pushed.blank?
        index_document['last_updated'] = resource.admin_data.last_updated if !resource.admin_data.last_updated.blank?
        index_document['needs_update'] = resource.admin_data.needs_update if !resource.admin_data.needs_update.blank?
      end
    end
  end
end
