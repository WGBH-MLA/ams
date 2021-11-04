require 'sony_ci_api'

module SonyCi
  class APIController < ::APIController

    respond_to :json

    # Specify error handlers for different kinds of errors. NOTE: for *all*
    # endpoints, we *always* want to respond with JSON and an appropriate HTTP
    # error, regardless of success or error. We *never* want to accidentally
    # render HTML, or anything other than JSON. This is the contract with
    # consumers, and if we violate it we'll break JS elsewhere. In order to
    # guarantee this, each error handler must have additional rescue clauses
    # to catch any additional exceptions, and render as JSON.
    rescue_from StandardError, with: :handle_error
    rescue_from SonyCiApi::Error, with: :handle_sony_ci_api_error
    rescue_from SonyCiApi::HttpError, with: :handle_sony_ci_api_http_error
    rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing_error

    # Returns a list of Sony Ci records that result from searching for
    # params[:query].
    def find_media
      result = sony_ci_api.workspace_search(
        query: permitted_params.require(:query),
        fields: return_fields,
        kind: "Asset"
      )
      render json: result
    end

    # Returns a JSON object with the ID and Name of the Sony Ci Record if found
    # from params[:sony_ci_id]
    def get_filename
      sony_ci_id = params.require(:sony_ci_id)
      result = sony_ci_api.asset(sony_ci_id)
      render json: { 'sony_ci_id' => sony_ci_id, 'name' => result['name'] }
    end

    private

        # Memoized accessor for the SonyCiApi::Client instance.
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

        # Renders generic JSON error object with 500 status.
        def render_basic_error(error)
          render json: { "error" => error.class.to_s, "error_message" => error.message }, status: 500
        end

        # Default error handler.
        def handle_error(error)
          render_basic_error(error)
        rescue => secondary_error
          render_basic_error(secondary_error)
        end

        # Error handler for SonyCiApi::Error errors.
        # Renders JSON from the error object with a default 500 status.
        def handle_sony_ci_api_error(sony_ci_api_error)
          render json: sony_ci_api_error.to_h, status: 500
        rescue => secondary_error
          render_basic_error(secondary_error)
        end

        # Error handler for SonyCiApi::HttpError errors.
        # Renders JSON from the error object, with a status also from the error
        # object, which will be something between 400 and 599.
        def handle_sony_ci_api_http_error(sony_ci_api_http_error)
          render json: sony_ci_api_http_error.to_h, status: sony_ci_api_http_error.http_status
        rescue => secondary_error
          render_basic_error(secondary_error)
        end

        def handle_parameter_missing_error(parameter_missing_error)
          render json: { "error" => "Missing Parameter", "error_message" => parameter_missing_error.message }, status: 400
        rescue => secondary_error
          render_basic_error(secondary_error)
        end
  end
end
