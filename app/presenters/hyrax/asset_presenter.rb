# Generated via
#  `rails generate hyrax:work Asset`
module Hyrax
  class AssetPresenter < Hyrax::WorkShowPresenter
    delegate :id, :genre, :asset_types, :broadcast_date, :created_date, :copyright_date,
             :episode_number, :spatial_coverage, :temporal_coverage,
             :audience_level, :audience_rating, :annotation, :rights_summary, :rights_link,
             :date, :local_identifier, :pbs_nola_code, :eidr_id, :topics, :subject,
             :program_title, :episode_title, :segment_title, :raw_footage_title, :promo_title, :clip_title, :description,
             :program_description, :episode_description, :segment_description, :raw_footage_description,
             :promo_description, :clip_description, :copyright_date,
             :level_of_user_access, :minimally_cataloged, :outside_url, :special_collection, :transcript_status,
             :sonyci_id, :licensing_info, :producing_organization, :series_title, :series_description,
             :playlist_group, :playlist_order, :hyrax_batch_ingest_batch_id, :last_pushed, :last_update, :needs_update,
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

    def last_pushed
      # DateTime.strptime(solr_document['last_pushed'], '%Y-%m-%dT%H:%M:%SZ',).strftime('%m-%e-%y %H:%M') if solr_document['last_pushed']
      DateTime.new(solr_document['last_pushed']).strftime('%m-%e-%y %H:%M') if solr_document['last_pushed']
    end

    def last_updated
      # DateTime.strptime(solr_document['last_updated'], '%Y-%m-%dT%H:%M:%SZ',).strftime('%m-%e-%y %H:%M') if solr_document['last_updated']
      DateTime.new(solr_document['last_updated']).strftime('%m-%e-%y %H:%M') if solr_document['last_updated']
    end

    def needs_update
      solr_document['needs_update']
    end

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
          playlist_order.blank? &&
          hyrax_batch_ingest_batch_id.blank? &&
          last_updated.blank? &&
          last_pushed.blank? &&
          needs_update.blank?
        )
    end

    def iiif_version
      if media_available?
        3
      else
        2
      end
    end

    def iiif_viewer?
      true
    end

    def file_set_presenters
      return [AMS::AssetFilePresenter.new(solr_document)]
    end

    def iiif_viewer
      :avalon
    end

    def ranges
      unless solr_document['media'].nil?
        [
          Hyrax::IiifAv::ManifestRange.new(
            label: { '@none'.to_sym => title.first },
            items: file_set_presenters.collect(&:range)
          )
        ]
      else
        return [ ]
      end
    end

    def media_available?
      solr_document.find_child(DigitalInstantiation).each do |instantiation|
        if  ( instantiation_have_essence_tracks(instantiation) &&
            instantiation_have_generation_proxy(instantiation) &&
            instantiation_have_holding_organization_aapb(instantiation) )
          solr_document['media'] = []
          instantiation.find_child(EssenceTrack).each do |track|
            if track.track_type.first == "video"
              solr_document['media'] << {
                :type => track.track_type.first,
                :height => track.frame_height.first,
                :width => track.frame_width.first,
                :duration => duration_to_sec(track.duration.first) }
            else
              solr_document['media'] << {
                :type => track.track_type.first,
                :duration => duration_to_sec(track.duration.first) }
            end
          end
          return true
        end
      end
      false
    end

    private

      def duration_to_sec(duration)
        durationDT = DateTime.parse(duration)
        durationDT.hour*60*60 + durationDT.min*60 + durationDT.sec
      end

      def instantiation_have_essence_tracks(instantiation)
        instantiation.fetch(:member_ids_ssim, []).size > 0
      end

      def instantiation_have_generation_proxy(instantiation)
        ( instantiation.generations && instantiation.generations.include?("Proxy") )
      end

      def instantiation_have_holding_organization_aapb(instantiation)
        (instantiation.holding_organization && instantiation.holding_organization.include?("American Archive of Public Broadcasting"))
      end
  end
end
