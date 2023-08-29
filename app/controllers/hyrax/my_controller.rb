# This is an override of Hyrax 2.2.4 [hyrax/app/controllers/hyrax/my_controller.rb]
# The override adds hyrax_batch_ingest_batch_id to the configure_facets class method
# WARNING: upgrading Hyrax may break this override

module Hyrax
  class MyController < ApplicationController
    include Hydra::Catalog
    include Hyrax::Collections::AcceptsBatches

    # Define filter facets that apply to all repository objects.
    def self.configure_facets
      # clear facet's copied from the CatalogController
      blacklight_config.facet_fields = {}
      configure_blacklight do |config|
        # TODO: add a visibility facet (requires visibility to be indexed)
        config.add_facet_field solr_name('visibility', :stored_sortable),
                               helper_method: :visibility_badge,
                               limit: 5, label: I18n.t('hyrax.dashboard.my.heading.visibility')
        config.add_facet_field IndexesWorkflow.suppressed_field, helper_method: :suppressed_to_status
        config.add_facet_field solr_name("resource_type", :facetable), limit: 5
        config.add_facet_field solr_name("hyrax_batch_ingest_batch_id", :stored_searchable)
        config.add_facet_field solr_name("bulkrax_importer_id", :stored_searchable)
      end
    end

    with_themed_layout 'dashboard'

    include Blacklight::Configurable

    copy_blacklight_config_from(CatalogController)
    configure_facets

    before_action :authenticate_user!
    load_and_authorize_resource only: :show, instance_name: :collection

    # include the render_check_all view helper method
    helper Hyrax::BatchEditsHelper
    # include the display_trophy_link view helper method
    helper Hyrax::TrophyHelper

    def index
      @user = current_user
      (@response, @document_list) = query_solr
      prepare_instance_variables_for_batch_control_display

      respond_to do |format|
        format.html {}
        format.rss  { render layout: false }
        format.atom { render layout: false }
      end
    end

    private

      # TODO: Extract a presenter object that wrangles all of these instance variables.
      def prepare_instance_variables_for_batch_control_display
        # set up some parameters for allowing the batch controls to show appropriately
        max_batch_size = 80
        count_on_page = @document_list.count { |doc| batch.index(doc.id) }
        @disable_select_all = @document_list.count > max_batch_size
        @result_set_size = @response.response["numFound"]
        @empty_batch = batch.empty?
        @all_checked = (count_on_page == @document_list.count)
        @add_works_to_collection = params.fetch(:add_works_to_collection, '')
        @add_works_to_collection_label = params.fetch(:add_works_to_collection_label, '')
      end

      def query_solr
        Hyrax::SearchService.new(config: blacklight_config,
                                  scope: self,
                                  user_params: params,
                                  search_builder_class: blacklight_config.search_builder_class).search_results
      end
  end
end
