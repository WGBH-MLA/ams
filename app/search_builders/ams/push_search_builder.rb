module AMS
  class PushSearchBuilder < Hyrax::CatalogSearchBuilder
    self.default_processor_chain += [:leave_fq_alone]
    # def models
    #   [Asset]
    # end

    def leave_fq_alone(solr_parameters)
      solr_parameters[:fq] = [%(has_model_ssim:Asset)]
      solr_parameters[:q] = %(needs_update:true)
      solr_parameters
    end
  end
end 