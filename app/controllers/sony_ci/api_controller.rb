require 'sony_ci_api'

class FooError < StandardError; end

module SonyCi
  class APIController < ::APIController
    rescue_from StandardError, with: :handle_error
    rescue_from SonyCiApi::Error, with: :handle_sony_ci_api_error

    def find_media
      result = sony_ci_api.workspace_search(
        query: permitted_params.require(:query),
        fields: return_fields,
        kind: "Asset"
      )
      render json: result
    end

    def get_filename
      sony_ci_id = params.require(:sony_ci_id)
      result = sony_ci_api.asset(sony_ci_id)
      render json: { 'sony_ci_id' => sony_ci_id, 'name' => result['name'] }
    end

    private

        def sony_ci_api
          @sony_ci_api ||= SonyCiApi::Client.new('config/ci.yml')
        end

        # Sony Ci will return 'id', 'name', and 'kind' plus any other fields
        # specified in a comma-separated list in :fields param. An empty string
        # for the :fields param will return all fields. If :fields is nil,
        # specify 'createdOn' as an additional default field.
        def return_fields
          params[:fields] || 'createdOn'
        end

        def permitted_params
          params.permit(:query, :fields)
        end

        # Default error handler. Respond with JSON error and 500
        def handle_error(error)
          render json: { error: error.class.to_s, error_message: error.message }, status: status
        end

        # Error handler for SonyCiApi::Error and subclasses thereof.
        def handle_sony_ci_api_error(error)
          render json: error.to_h, status: error.http_status
        end
  end
end
