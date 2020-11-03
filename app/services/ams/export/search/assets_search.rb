module AMS
  module Export
    module Search
      class AssetsSearch < Base
        def response
          @response ||= search_results(search_params)[0]
        end

        def response_without_rows
          @response_without_rows ||= search_results(search_params.merge(rows: 0))[0]
        end
      end
    end
  end
end
