module AMS
  module Export
    module Search
      class CatalogSearch < Base
        # Include Blacklight modules that provide methods for configurating and
        # performing searches.

        # this is required - advanced_search will crash without it
        copy_blacklight_config_from(CatalogController)
        configure_blacklight do |config|
          # This is necessary to prevent Blacklight's default value of 100 for
          # config.max_per_page from capping the number of results.
          config.max_per_page = MAX_LIMIT
        end

        private
          # Overwrite Base#response to use Blacklight::SearchHelper#search_results.
          def response
            @response ||= Hyrax::SearchService.new(
                            config: CatalogController.blacklight_config,
                            user_params: search_params,
                            scope: self,
                            current_ability: user.ability
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
