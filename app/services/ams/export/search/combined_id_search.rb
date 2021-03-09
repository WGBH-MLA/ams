module AMS
  module Export
    module Search
      class CombinedIDSearch < CombinedSearch
        attr_reader :ids, :user, :model_name
        def initialize(ids:, user:, model_name: nil)
          @ids = ids
          @user = user
          @model_name = model_name
          super(searches: id_searches)
        end

        private

          def id_searches
            @id_searches ||= [].tap do |searches|
              ids.each_slice(IDSearch::MAX_IDS_PER_QUERY) do |ids_slice|
                searches << IDSearch.new(ids: ids_slice, user: user, model_name: model_name)
              end
            end
          end
      end
    end
  end
end
