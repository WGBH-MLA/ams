module AMS
  class PushSearchBuilder < Hyrax::CatalogSearchBuilder
    self.default_processor_chain += [:pass_q_to_fq]

    def pass_q_to_fq(solr_params)
      solr_params[:fq] = solr_params[:q]
      solr_params[:q] = ''
      solr_params
    end

  end
end