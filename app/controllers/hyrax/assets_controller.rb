# Generated via
#  `rails generate hyrax:work Asset`

module Hyrax
  class AssetsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    # Handle Child Work button and redirect to child work page
    include Hyrax::ChildWorkRedirect
    self.curation_concern_type = ::Asset

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::AssetPresenter
  end
end
