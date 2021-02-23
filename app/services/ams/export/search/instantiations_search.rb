module AMS
  module Export
    module Search
      class InstantiationsSearch < Base
        def response
          @response ||= solr.search(instantiations_search_params)
        end

        def response_without_rows
          params = instantiations_search_params.merge(rows: 0)
          @response_without_rows ||= solr.search(params)
        end

        private

          def model_name
            raise "#{self.class}##{__method__} must be implemented to return " \
                  "the value for has_model_ssim."
          end

          def solr
            @solr ||= Blacklight::Solr::Repository.new(blacklight_config)
          end

          def instantiations_search_params
            { q: "+id:(#{instantiation_ids.join(' OR ')}) has_model_ssim:#{model_name}", rows: MAX_LIMIT }
          end

          def instantiation_ids
            @instantiation_ids ||= asset_results.map(&:member_ids).flatten
          end

          def asset_results
            asset_search = AMS::Export::Search::AssetsSearch.new(search_params: search_params, user: user)
            asset_search.solr_documents
          end
      end
    end
  end
end
