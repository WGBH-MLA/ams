# Generated via
#  `rails generate hyrax:work Asset`
module Hyrax
  class AssetResourcePresenter < Hyrax::WorkShowPresenter
    include ActionView::Helpers::TagHelper

    delegate :id, :genre, :asset_types, :broadcast_date, :created_date, :copyright_date,
             :episode_number, :spatial_coverage, :temporal_coverage,
             :audience_level, :audience_rating, :annotation, :rights_summary, :rights_link,
             :date, :local_identifier, :pbs_nola_code, :eidr_id, :topics, :subject,
             :program_title, :episode_title, :segment_title, :raw_footage_title, :promo_title, :clip_title, :description,
             :program_description, :episode_description, :segment_description, :raw_footage_description,
             :promo_description, :clip_description, :copyright_date, :validation_status_for_aapb,
             :level_of_user_access, :outside_url, :special_collections, :transcript_status, :organization,
             :sonyci_id, :licensing_info, :producing_organization, :series_title, :series_description,
             :playlist_group, :playlist_order, :hyrax_batch_ingest_batch_id, :bulkrax_importer_id, :last_pushed, :last_update, :needs_update, :special_collection_category, :canonical_meta_tag, :cataloging_status,
             to: :solr_document

    def batch
      raise 'No Batch ID associated with this Asset' unless hyrax_batch_ingest_batch_id.first.present?
      @batch ||= Hyrax::BatchIngest::Batch.find(hyrax_batch_ingest_batch_id.first)
    end

    def batch_url
      @batch_url ||= "/batches/#{batch.id}"
    end

    def batch_ingest_label
      @batch_ingest_label ||= Hyrax::BatchIngest.config.ingest_types[batch.ingest_type.to_sym].label
    end

    def batch_ingest_date
      @batch_ingest_date ||= Date.parse(batch.created_at.to_s)
    end

    def bulkrax_import
      raise 'No Bulkrax Import ID associated with this Asset' unless bulkrax_importer_id.present?
      @bulkrax_import ||= Bulkrax::Importer.find(bulkrax_importer_id.first)
    end

    def bulkrax_import_url
      @bulkrax_import_url ||= "/importers/#{bulkrax_import.id}"
    end

    def bulkrax_import_label
      @bulkrax_import_ingest_label ||= bulkrax_import.parser_klass
    end

    def bulkrax_import_date
      @bulkrax_import_ingest_date ||= Date.parse(bulkrax_import.updated_at.to_s)
    end

    def annotations
      @annotations ||= Hyrax.query_service.find_by(id: solr_document['id']).annotations
    end

    def aapb_badge
      if validation_status_for_aapb.to_a.include?('valid')
        tag.span('AAPB Valid', class: "aapb-badge badge badge-success")
      elsif validation_status_for_aapb.blank?
        tag.span('Not AAPB Validated', class: "aapb-badge badge badge-warning")
      else
        tag.span(validation_status_for_aapb.join(", ").humanize, class: "aapb-badge badge badge-danger")
      end
    end

    def last_pushed
      timestamp_to_display_date solr_document['last_pushed']
    end

    def last_updated
      timestamp_to_display_date solr_document['last_updated']
    end

    def needs_update
      solr_document['needs_update']
    end

    def filter_item_ids_to_display(solr_query)
      return [] if authorized_item_ids.empty?
      query_ids = authorized_item_ids.map {|id| "id:#{id}"} .join(" OR ")
      solr_query += " AND (#{query_ids})"
      Hyrax::SolrService.query(solr_query, rows: 10_000, fl: "id").map(&:id)
    end

    def list_of_instantiation_ids_to_display
      query = "(has_model_ssim:DigitalInstantiationResource OR has_model_ssim:PhysicalInstantiationResource OR has_model_ssim:DigitalInstantiation OR has_model_ssim:PhysicalInstantiation) "
      authorized_instantiation_ids = filter_item_ids_to_display(query)
      paginated_item_list(page_array: authorized_instantiation_ids)
    end

    def list_of_contribution_ids_to_display
      query = "(has_model_ssim:ContributionResource OR has_model_ssim:Contribution) "
      authorized_contribution_ids = filter_item_ids_to_display(query)
      paginated_item_list(page_array: authorized_contribution_ids)
    end

    def display_aapb_admin_data?
      ! ( sonyci_id.blank? &&
          bulkrax_importer_id.blank? &&
          hyrax_batch_ingest_batch_id.blank? &&
          last_updated.blank? &&
          last_pushed.blank? &&
          needs_update.blank?
        )
    end

    def display_annotations?
      return true if Annotation.registered_annotation_types.values.map{ |type| solr_document.send(type.to_sym).present? }.uniq.include?(true)
      false
    end

    def media_available?
      sonyci_id.blank? ? false : true
    end

    private

      def timestamp_to_display_date(timestamp)
        ApplicationHelper.display_date(timestamp, format: '%m-%e-%y %H:%M %Z', from_format: '%s', time_zone: 'US/Eastern')
      end
  end
end
