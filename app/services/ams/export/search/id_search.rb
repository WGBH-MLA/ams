module AMS
  module Export
    module Search
      class IDSearch < Base

        MAX_IDS_PER_QUERY = 100

        attr_reader :ids, :model_class_name

        def initialize(ids:, user:, model_class_name: nil)
          raise "Max number of IDs per query is #{MAX_IDS_PER_QUERY}, but #{ids.count} was given" unless ids.count <= MAX_IDS_PER_QUERY
          @ids, @model_class_name = ids, model_class_name
          super(search_params: id_search_params, user: user)
        end

        private

          def id_search_params
            @id_search_params ||= {}.tap do |params|
              params[:q] = "+id:(#{ids.join(' OR ')})"
              params[:q] += " has_model_ssim:#{model_class_name}" if model_class_name
            end
          end
      end
    end
  end
end
