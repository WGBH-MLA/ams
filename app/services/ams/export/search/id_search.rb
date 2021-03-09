module AMS
  module Export
    module Search
      class IDSearch < Base

        MAX_IDS_PER_QUERY = 100

        attr_reader :ids

        def initialize(ids:, user:, model_name: nil)
          raise "Max number of IDs per query is #{MAX_IDS_PER_QUERY}, but #{ids.count} was given" unless ids.count <= MAX_IDS_PER_QUERY
          @ids, @user, @model_name = ids, user, model_name
          super(search_params: id_search_params, user: user)
        end

        private

          def id_search_params
            @id_search_paramsm ||= {}.tap do |params|
              params[:q] = "+id:(#{ids.join(' OR ')})"
              params[:q] += " has_model_ssim:#{model_name}" if model_name
            end
          end
      end
    end
  end
end
