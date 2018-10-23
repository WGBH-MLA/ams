# Generated via
#  `rails generate hyrax:work Asset`
module Hyrax
  class AssetPresenter < Hyrax::WorkShowPresenter
    # Adds behaviors for hyrax-iiif_av plugin.
    include Hyrax::IiifAv::DisplaysIiifAv
    Hyrax::MemberPresenterFactory.file_presenter_class = Hyrax::IiifAv::IiifFileSetPresenter

    # Optional override to select iiif viewer to render
    # default :avalon for audio and video, :universal_viewer for images
    # def iiif_viewer
    #   :avalon
    # end
    delegate :genre, :asset_types, :broadcast_date, :created_date, :copyright_date,
             :episode_number, :spatial_coverage, :temporal_coverage,
             :audience_level, :audience_rating, :annotation, :rights_summary, :rights_link,
             :date, :local_identifier, :pbs_nola_code, :eidr_id, :topics, :subject,
             :program_title, :episode_title, :segment_title, :raw_footage_title, :promo_title, :clip_title, :description,
             :program_description, :episode_description, :segment_description, :raw_footage_description,
             :promo_description, :clip_description, :copyright_date,
             :level_of_user_access, :minimally_cataloged, :outside_url, :special_collection, :transcript_status,
             :sonyci_id, :licensing_info, :producing_organization, :series_title, :series_description,
             :playlist_group, :playlist_order,
             to: :solr_document

    def filter_item_ids_to_display(solr_query)
      return [] if authorized_item_ids.empty?
      query_ids = authorized_item_ids.map {|id| "id:#{id}"} .join(" OR ")
      solr_query += " AND (#{query_ids})"
      ActiveFedora::SolrService.query(solr_query,rows: 10_000,fl: "id").map(&:id)
    end

    def list_of_instantiation_ids_to_display
      query = "(has_model_ssim:DigitalInstantiation OR has_model_ssim:PhysicalInstantiation) "
      authorized_instantiation_ids = filter_item_ids_to_display(query)
      paginated_item_list(page_array: authorized_instantiation_ids)
    end

    def list_of_contribution_ids_to_display
      query = "(has_model_ssim:Contribution) "
      authorized_contribution_ids = filter_item_ids_to_display(query)
      paginated_item_list(page_array: authorized_contribution_ids)
    end

    def display_aapb_admin_data?
      ! ( level_of_user_access.blank? &&
          minimally_cataloged.blank? &&
          outside_url.blank? &&
          special_collection.blank? &&
          transcript_status.blank? &&
          sonyci_id.blank? &&
          licensing_info.blank? &&
          playlist_group.blank? &&
          playlist_order.blank?
        )
    end
  end
end
