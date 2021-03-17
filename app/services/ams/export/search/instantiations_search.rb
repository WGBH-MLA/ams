module AMS
  module Export
    module Search
      class InstantiationsSearch < CatalogSearch
        def solr_documents
          combined_id_search.solr_documents
        end

        def num_found
          combined_id_search.num_found
        end

        private

          def model_class_name
            raise "#{self.class}##{__method__} must be implemented to return " \
                  "the value for has_model_ssim."
          end

          def combined_id_search
            @combined_id_search ||= AMS::Export::Search::CombinedIDSearch.new(ids: asset_member_ids, model_class_name: model_class_name, user: user)
          end

          def asset_member_ids
            @asset_member_ids ||= assets_search.solr_documents.map(&:member_ids).flatten
          end

          def assets_search
            @assets_search ||= AMS::Export::Search::CatalogSearch.new(search_params: search_params, user: user)
          end
      end
    end
  end
end
