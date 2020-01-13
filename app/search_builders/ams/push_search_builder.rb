module AMS
  class PushSearchBuilder < Hyrax::CatalogSearchBuilder
    self.default_processor_chain += [:leave_fq_alone]

    def leave_fq_alone(solr_parameters)
      solr_parameters[:fq] = [%(has_model_ssim:Asset)]
      # solr_parameters[:q] = %(needs_update:true)
      solr_parameters[:rows] = 2147483647

      if blacklight_params && blacklight_params[:qf]
        solr_parameters[:qf] = blacklight_params[:qf]
      end
      solr_parameters
    end
  end
end 