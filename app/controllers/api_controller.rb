class APIController < ActionController::API
  # Gives us respond_to in controller actions which we use to respond with
  # JSON or PBCore XML.
  include ActionController::MimeResponds

  # Common API features here, e.g. auth.
  rescue_from ActiveFedora::ObjectNotFoundError, with: :not_found

  private

  def not_found(error)
    # TODO: render errors in the proper format: xml or json.
    render text: "Not Found", status: 404
  end
end
