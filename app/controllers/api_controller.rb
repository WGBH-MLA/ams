class APIController < ActionController::API
  # Gives us respond_to in controller actions which we use to respond with
  # JSON or PBCore XML.
  include ActionController::MimeResponds

  # Authenticate user before all actions.
  # NOTE: For Basic HTTP auth to work:
  #   * the `http_authenticatable` config option for Devise must be set to true
  #     (see config/initializers/devise.rb).
  #   * The Authorization request header must be set to "Basic {cred}" where
  #     {cred} is the base64 encoded username:password.
  before_action do
    authenticate_user!
  end

  # Common API features here, e.g. auth.
  rescue_from ActiveFedora::ObjectNotFoundError, with: :not_found

  private

  def not_found(error)
    # TODO: render errors in the proper format: xml or json.
    render text: "Not Found", status: 404
  end
end
