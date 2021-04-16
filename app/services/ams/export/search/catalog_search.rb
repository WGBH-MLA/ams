module AMS
  module Export
    module Search
      class CatalogSearch < Base
        # Include Blacklight modules that provide methods for configurating and
        # performing searches.
        include Blacklight::SearchHelper

        # this is required - advanced_search will crash without it
        copy_blacklight_config_from(CatalogController)
        configure_blacklight do |config|
          # This is necessary to prevent Blacklight's default value of 100 for
          # config.max_per_page from capping the number of results.
          config.max_per_page = MAX_LIMIT
        end

        private
          # Overwrite Base#response to use Blacklgiht::SearchHelper#search_results.
          def response
            @response ||= search_results(search_params)[0]
          end

          # Overwrite Base#response to use Blacklgiht::SearchHelper#search_results.
          def response_without_rows
            @response_without_rows ||= search_results(search_params.merge(rows: 0))[0]
          end
      end
    end
  end
end
