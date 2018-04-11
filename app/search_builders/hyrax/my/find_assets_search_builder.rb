# Search for possible works that user can edit and could be a work's child or parent.
class Hyrax::My::FindAssetsSearchBuilder < Hyrax::My::SearchBuilder
  include Hyrax::FilterByType

  self.default_processor_chain += [:filter_on_title]
  self.default_processor_chain -= [:add_access_controls_to_solr_params, :show_only_resources_deposited_by_current_user]

  # Excludes the id that is part of the params
  def initialize(context)
    super(context)
    # Without an id this class will produce an invalid query.
    @id = context.params[:id] || raise("missing required parameter: id")
    @q = context.params[:q]
  end

  def filter_on_title(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] += [ActiveFedora::SolrQueryBuilder.construct_query(title_tesim: @q)]
  end

  private

    def models
      [Asset]
    end
end
