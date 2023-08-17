class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include Hydra::Controller::ControllerBehavior

  # Adds Hyrax behaviors into the application controller
  include Hyrax::Controller
  include Hyrax::ThemedLayoutController
  with_themed_layout '1_column'


  protect_from_forgery with: :exception

  # This is an easy way for us to make changes to the views folder without
  # having to add a bunch of conditionals.  We are doing a Bootrstrap 3 to 4 upgrade.
  # Remove this after the Rails 6.1 upgrade
  before_action :set_view_paths
  def set_view_paths
    unless App.rails_5_1?
      prepend_view_path "app/views_rails_6_1"
    end
  end
end
