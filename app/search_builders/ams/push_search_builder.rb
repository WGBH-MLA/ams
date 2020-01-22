module AMS
  class PushSearchBuilder < Hyrax::CatalogSearchBuilder
    # this space intentionally left blank 
        # Add date filters to the processor chain.
    self.default_processor_chain += [:pass_q_to_fq]

    # Adds date filters to the :fq of the solr params.
    def pass_q_to_fq(solr_params)
      solr_params[:fq] = solr_params[:q]
      solr_params[:q] = ''
      solr_params
    end

  end
end