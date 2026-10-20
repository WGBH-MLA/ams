class CatalogController < ApplicationController
  include Hydra::Catalog
  include BlacklightAdvancedSearch::Controller

  # This filter applies the hydra access controls
  before_action :enforce_show_permissions, only: :show
  
  configure_blacklight do |config|
    # default advanced config values
    config.advanced_search ||= Blacklight::OpenStructWithHashAccess.new
    config.advanced_search[:url_key] ||= 'advanced'
    config.advanced_search[:query_parser] ||= 'dismax'
    config.advanced_search[:form_solr_parameters] ||= {}

    config.view.gallery(document_component: Blacklight::Gallery::DocumentComponent)
    config.view.masonry(document_component: Blacklight::Gallery::DocumentComponent)
    config.view.slideshow(document_component: Blacklight::Gallery::SlideshowComponent)

    config.show.tile_source_field = :content_metadata_image_iiif_info_ssm
    config.show.partials.insert(1, :openseadragon)
    config.search_builder_class = AMS::SearchBuilder

    config.index.search_bar_presenter_class = Blacklight::ShowPresenter

    # Show gallery view
    config.view.gallery.partials = [:index_header, :index]
    config.view.slideshow.partials = [:index]

    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      qt: "search",
      rows: 10
    }

    # Solr field configuration for document/show views
    config.index.title_field = 'title_tesim'
    config.index.display_type_field = 'has_model_ssim'
    config.index.thumbnail_field = 'thumbnail_path_ss'
    config.index.thumbnail_method = :render_thumbnail

    config.add_results_document_tool(:bookmark, partial: 'bookmark_control', if: :render_bookmarks_control?)
    config.add_results_collection_tool(:sort_widget)
    config.add_results_collection_tool(:per_page_widget)
    config.add_results_collection_tool(:view_type_group)
    config.add_show_tools_partial(:bookmark, partial: 'bookmark_control', if: :render_bookmarks_control?)
    config.add_show_tools_partial(:email, callback: :email_action, validator: :validate_email_params)
    config.add_show_tools_partial(:sms, if: :render_sms_action?, callback: :sms_action, validator: :validate_sms_params)
    config.add_show_tools_partial(:citation)
    config.add_nav_action(:bookmark, partial: 'blacklight/nav/bookmark', if: :render_bookmarks_control?)
    config.add_nav_action(:search_history, partial: 'blacklight/nav/search_history')

    config.add_results_collection_tool :export_search_results

    # =========================================================================
    # FACETS (Configured with Valkyrie Solr suffixes)
    # =========================================================================
    config.add_facet_field "asset_types_sim", label: "Asset Type", limit: 5, collapse: true
    config.add_facet_field "topics_sim", label: "Topic", limit: 5, collapse: true
    config.add_facet_field "genre_sim", label: "Genre", limit: 5, collapse: true
    config.add_facet_field "producing_organization_sim", label: "Producing Organization", limit: 5, collapse: true
    config.add_facet_field "media_type_sim", label: "Media Type", limit: 5, collapse: true
    config.add_facet_field "format_sim", label: "Physical Format", limit: 5, collapse: true
    config.add_facet_field "holding_organization_sim", label: "Holding Organization", limit: 5, collapse: true
    config.add_facet_field "language_sim", label: "Language", limit: 5, collapse: true
    config.add_facet_field "level_of_user_access_ssim", label: "Level of user access", limit: 5, collapse: true
    config.add_facet_field "transcript_status_ssim", label: "Transcript Status", limit: 5, collapse: true
    config.add_facet_field "hyrax_batch_ingest_batch_id_tesim"

    config.add_facet_field 'cataloging_status_ssim', query: {
      yes: { label: 'Yes', fq: 'cataloging_status_ssim:Yes' },
      no:  { label: 'No',  fq: '-cataloging_status_ssim:[* TO *]' }
    }, label: "Minimally Cataloged", collapse: true

    config.add_facet_field 'outside_url_ssim', query: {
      yes: { label: 'Yes', fq: 'outside_url_ssim:[* TO *]' },
      no:  { label: 'No',  fq: '-outside_url_ssim:[* TO *]' }
    }, label: "Outside URL", collapse: true

    config.add_facet_field 'sonyci_id_ssim', query: {
      yes: { label: 'Yes', fq: 'sonyci_id_ssim:[* TO *]' },
      no:  { label: 'No',  fq: '-sonyci_id_ssim:[* TO *]' }
    }, label: "Digitized Copy in AAPB", collapse: true

    config.add_facet_field "generic_type_sim", if: false

    config.add_facet_fields_to_solr_request!

    # =========================================================================
    # SEARCH RESULTS (INDEX) FIELDS
    # =========================================================================
    config.add_index_field 'id', label: 'GUID'
    config.add_index_field 'title_tesim', label: "Title", itemprop: 'name', if: false
    config.add_index_field "description", accessor: "display_description"
    config.add_index_field 'created_date_tesim', label: 'Created Date', itemprop: 'created_date', helper_method: :iconify_auto_link
    config.add_index_field 'copyright_date_tesim', itemprop: 'copyright_date', helper_method: :iconify_auto_link
    config.add_index_field 'broadcast_date_tesim', label: 'Broadcast Date', itemprop: 'broadcast_date', helper_method: :iconify_auto_link
    config.add_index_field 'holding_organization_tesim', label: 'Holding Organization'
    config.add_index_field 'local_instantiation_identifier_tesim', label: 'Local Instantiation ID'
   
    # =========================================================================
    # SHOW (DETAIL) FIELDS
    # =========================================================================
    config.add_show_field "id"
    config.add_show_field "title_tesim"
    config.add_show_field "series_title_tesim"
    config.add_show_field "raw_footage_title_tesim"
    config.add_show_field "segment_title_tesim"
    config.add_show_field "program_title_tesim"
    config.add_show_field "episode_title_tesim"
    config.add_show_field "clip_title_tesim"
    config.add_show_field "promo_title_tesim"

    config.add_show_field "date_tesim"
    config.add_show_field "broadcast_date_tesim"
    config.add_show_field "created_date_tesim"
    config.add_show_field "copyright_date_tesim"

    config.add_show_field "description_tesim"
    config.add_show_field "series_description_tesim"
    config.add_show_field "raw_footage_description_tesim"
    config.add_show_field "segment_description_tesim"
    config.add_show_field "program_description_tesim"
    config.add_show_field "episode_description_tesim"
    config.add_show_field "clip_description_tesim"
    config.add_show_field "promo_description_tesim"
    config.add_show_field "rundown_description_tesim"

    config.add_show_field "producing_organization_tesim"
    config.add_show_field "episode_number_tesim"
    config.add_show_field "genre_tesim"
    config.add_show_field "spatial_coverage_tesim"
    config.add_show_field "temporal_coverage_tesim"
    config.add_show_field "audience_level_tesim"
    config.add_show_field "audience_rating_tesim"
    config.add_show_field "annotation_tesim"
    config.add_show_field "rights_summary_tesim"
    config.add_show_field "rights_link_tesim"
    config.add_show_field "local_identifier_tesim"
    config.add_show_field "pbs_nola_code_tesim"
    config.add_show_field "eidr_id_tesim"
    config.add_show_field "topics_tesim"
    config.add_show_field "subject_tesim"

    # From Instantiations
    config.add_show_field "local_instantiation_identifier_tesim"
    config.add_show_field "holding_organization_tesim"

    # From Contributions
    config.add_show_field "contributor_tesim"
    config.add_show_field "affiliation_tesim"
    config.add_show_field "portrayal_tesim"

    # =========================================================================
    # SEARCH FIELDS & ADVANCED SEARCH
    # =========================================================================
    config.add_search_field('all_fields', label: 'All Fields') do |field|
      all_names = config.show_fields.values.map(&:field).join(" ")
      field.include_in_advanced_search = false
      field.solr_parameters = {
        qf: "#{all_names} file_format_tesim all_text_timv",
        pf: 'title_tesim'
      }
    end

    config.add_search_field('all_titles') do |field|
      field.label = "Titles (All)"
      titles_qf = 'title_tesim series_title_tesim program_title_tesim episode_title_tesim segment_title_tesim raw_footage_title_tesim promo_title_tesim clip_title_tesim'
      field.solr_parameters = {
        qf: titles_qf,
        pf: titles_qf
      }
    end

    config.add_search_field('series_title') do |field|
      field.label = "Series Title"
      field.solr_parameters = {
        qf: 'series_title_tesim',
        pf: 'series_title_tesim'
      }
    end

    config.add_search_field('all_descriptions') do |field|
      field.label = "Descriptions (All)"
      descriptions_qf = 'description_tesim series_description_tesim raw_footage_description_tesim segment_description_tesim program_description_tesim episode_description_tesim clip_description_tesim promo_description_tesim rundown_description_tesim'
      field.solr_parameters = {
        qf: descriptions_qf,
        pf: descriptions_qf
      }
    end

    config.add_search_field('contributor') do |field|
      field.label = "Contributor"
      field.solr_parameters = {
        qf: 'contributor_tesim portrayal_tesim affiliation_tesim',
        pf: 'contributor_tesim'
      }
    end

    config.add_search_field('creator') do |field|
      field.include_in_advanced_search = false
      field.solr_parameters = {
        qf: 'creator_tesim',
        pf: 'creator_tesim'
      }
    end

    config.add_search_field('title') do |field|
      field.include_in_advanced_search = false
      field.solr_parameters = {
        qf: 'title_tesim',
        pf: 'title_tesim'
      }
    end

    config.add_search_field('description') do |field|
      field.label = "Abstract or Summary"
      field.include_in_advanced_search = false
      field.solr_parameters = {
        qf: 'description_tesim',
        pf: 'description_tesim'
      }
    end

    config.add_search_field('publisher') do |field|
      field.include_in_advanced_search = false
      field.solr_parameters = {
        qf: 'publisher_tesim',
        pf: 'publisher_tesim'
      }
    end

    config.add_search_field('date_created') do |field|
      field.include_in_advanced_search = false
      field.solr_parameters = {
        qf: 'created_date_tesim',
        pf: 'created_date_tesim'
      }
    end

    config.add_search_field('subject') do |field|
      field.label = "Subject"
      field.solr_parameters = {
        qf: 'subject_tesim topics_tesim',
        pf: 'subject_tesim'
      }
    end

    config.add_search_field('language') do |field|
      field.include_in_advanced_search = false
      field.solr_parameters = {
        qf: 'language_tesim',
        pf: 'language_tesim'
      }
    end

    config.add_search_field('resource_type') do |field|
      field.include_in_advanced_search = false
      field.solr_parameters = {
        qf: 'resource_type_tesim',
        pf: 'resource_type_tesim'
      }
    end
    
    config.add_search_field('instantiation_format') do |field|
      field.include_in_advanced_search = false
      field.solr_parameters = {
        qf: 'format_tesim digital_format_tesim',
        pf: 'format_tesim'
      }
    end

    config.add_search_field('local_identifier') do |field|
      field.label = 'Local ID'
      field.solr_parameters = {
        qf: 'local_identifier_tesim id',
        pf: 'local_identifier_tesim'
      }
    end

    config.add_search_field('local_instantiation_identifier') do |field|
      field.label = 'Local Instantiation Identifier'
      field.solr_parameters = {
        qf: 'local_instantiation_identifier_tesim',
        pf: 'local_instantiation_identifier_tesim'
      }
    end

    config.add_search_field('holding_organization') do |field|
      field.label = 'Holding Organization'
      field.solr_parameters = {
        qf: 'holding_organization_tesim',
        pf: 'holding_organization_tesim'
      }
    end

    config.add_search_field('depositor') do |field|
      field.include_in_advanced_search = false
      field.solr_parameters = {
        qf: 'depositor_ssim',
        pf: 'depositor_ssim'
      }
    end

    config.add_search_field('rights_statement') do |field|
      field.include_in_advanced_search = false
      field.solr_parameters = {
        qf: 'rights_statement_tesim',
        pf: 'rights_statement_tesim'
      }
    end

    config.add_search_field('license') do |field|
      field.include_in_advanced_search = false
      field.solr_parameters = {
        qf: 'license_tesim',
        pf: 'license_tesim'
      }
    end

    config.add_search_field('broadcast') do |field|
      field.include_in_advanced_search = false
      field.solr_parameters = {
        qf: 'broadcast_date_tesim',
        pf: 'broadcast_date_tesim'
      }
    end

    config.add_search_field('created') do |field|
      field.include_in_advanced_search = false
      field.solr_parameters = {
        qf: 'created_date_tesim',
        pf: 'created_date_tesim'
      }
    end

    config.add_search_field('date') do |field|
      field.include_in_advanced_search = false
      field.solr_parameters = {
        qf: 'date_tesim',
        pf: 'date_tesim'
      }
    end

    config.add_search_field('copyright_date') do |field|
      field.include_in_advanced_search = false
      field.solr_parameters = {
        qf: 'copyright_date_tesim',
        pf: 'copyright_date_tesim'
      }
    end

    config.add_search_field('spatial_coverage') do |field|
      field.solr_parameters = {
        qf: 'spatial_coverage_tesim',
        pf: 'spatial_coverage_tesim'
      }
    end

    config.add_search_field('temporal_coverage') do |field|
      field.solr_parameters = {
        qf: 'temporal_coverage_tesim',
        pf: 'temporal_coverage_tesim'
      }
    end

    config.add_search_field('audience_level') do |field|
      field.solr_parameters = {
        qf: 'audience_level_tesim',
        pf: 'audience_level_tesim'
      }
    end

    config.add_search_field('audience_rating') do |field|
      field.solr_parameters = {
        qf: 'audience_rating_tesim',
        pf: 'audience_rating_tesim'
      }
    end

    config.add_search_field('rights_summary') do |field|
      field.solr_parameters = {
        qf: 'rights_summary_tesim',
        pf: 'rights_summary_tesim'
      }
    end

    config.add_search_field('pbs_nola_code') do |field|
      field.solr_parameters = {
        qf: 'pbs_nola_code_tesim',
        pf: 'pbs_nola_code_tesim'
      }
    end

    config.add_search_field('eidr_id') do |field|
      field.solr_parameters = {
        qf: 'eidr_id_tesim',
        pf: 'eidr_id_tesim'
      }
    end

    config.add_search_field('portrayal') do |field|
      field.solr_parameters = {
        qf: 'portrayal_tesim',
        pf: 'portrayal_tesim'
      }
    end

    # =========================================================================
    # SORT FIELDS (Decoupled from Solrizer)
    # =========================================================================
    config.add_sort_field "score desc, system_create_dtsi desc", label: "relevance"
    config.add_sort_field "system_create_dtsi desc", label: "date uploaded \u25BC"
    config.add_sort_field "system_create_dtsi asc", label: "date uploaded \u25B2"
    config.add_sort_field "system_modified_dtsi desc", label: "date modified \u25BC"
    config.add_sort_field "system_modified_dtsi asc", label: "date modified \u25B2"
    config.add_sort_field "broadcast_date_drsim desc", label: "broadcast \u25BC"
    config.add_sort_field "broadcast_date_drsim asc", label: "broadcast \u25B2"
    config.add_sort_field "created_date_drsim desc", label: "created  \u25BC"
    config.add_sort_field "created_date_drsim asc", label: "created  \u25B2"
    config.add_sort_field "copyright_date_drsim desc", label: "copyright date  \u25BC"
    config.add_sort_field "copyright_date_drsim asc", label: "copyright date  \u25B2"
    config.add_sort_field "date_drsim desc", label: "date  \u25BC"
    config.add_sort_field "date_drsim asc", label: "date  \u25B2"
    config.add_sort_field "title_si desc", label: "title  \u25BC"
    config.add_sort_field "title_si asc", label: "title  \u25B2"
    config.add_sort_field "episode_number_tesim desc", label: "Episode Number  \u25BC"
    config.add_sort_field "episode_number_tesim asc", label: "Episode Number  \u25B2"

    config.spell_max = 5
  end

  # disable the bookmark control from displaying in gallery view
  # Hyrax doesn't show any of the default controls on the list view, so
  # this method is not called in that context.
  def render_bookmarks_control?
    false
  end

  def export
    params.permit!

    if !export_search.valid?
      alert_msg = export_search.errors.messages.values.flatten.join("\n")
      redirect_to(search_catalog_url(search_params), alert: alert_msg) and return
    end

    if export_too_big_for_browser?
      ExportRecordsJob.perform_later(export_type: export_type, search_params: search_params, user: current_user)
      # TODO: add some job details to the flash msg
      msg = "Export job enqueued!"
      redirect_to(search_catalog_url(search_params), notice: msg) and return
    end

    # Export is not too big. Send the export they asked for.
    respond_to do |format|
      format.csv {
        send_file export_results.filepath, type: 'text/csv; charset=utf-8; header=present', filename: File.basename(export_results.filepath)
      }

      format.pbcore {
        send_file export_results.filepath, type: 'application/zip', filename: File.basename(export_results.filepath)
      }
    end
  end

  private

    def export_search
      @export_search ||= AMS::Export::Search.for_export_type(export_type).new(search_params: search_params, user: current_user)
    end

    def export_results
      AMS::Export::Results.for_export_type(export_type).new(solr_documents: export_search.solr_documents)
    end

    def search_params
      @search_params ||= params.except(:page,
                                       :action,
                                       :controller,
                                       :locale,
                                       :object_type,
                                       :format).permit!.to_h
    end

    def export_type
      # TODO: change param from :object_type to :export_type in the form for
      # clarity and consistency.
      params[:object_type]
    end

    def export_too_big_for_browser?
      export_search.num_found > Rails.configuration.max_export_to_browser_limit
    end

    def export_job_class
      AMS::Export::Job.get_job_class_for(export_type)
    end
end
