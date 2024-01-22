module AMS
  module Export
    module Search
      class CatalogSearch < Base
        # Include Blacklight modules that provide methods for configurating and
        # performing searches.

        private
          # Overwrite Base#response to use Blacklight::SearchHelper#search_results.
        def response
          blacklight_config = CatalogController.blacklight_config.dup
          blacklight_config.default_solr_params = { rows: 2_000_000 }
          blacklight_config.max_per_page = 2_000_000
            @response ||= Hyrax::SearchService.new(
                            config: blacklight_config,
                            user_params: search_params,
                            scope: self,
                            current_ability: user.ability,
                            rows: 2_000_000
                          ).search_results[0]
          end

          # Overwrite Base#response to use Blacklight::SearchHelper#search_results.
          def response_without_rows
            @response_without_rows ||= Hyrax::SearchService.new(
                                         config: CatalogController.blacklight_config,
                                         user_params: search_params.except(:rows),
                                         scope: self,
                                         current_ability: user.ability
                                       ).search_results[0]
          end
      end
    end
  end
end
