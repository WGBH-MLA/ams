# Generated via
#  `rails generate hyrax:work Asset`

module Hyrax
  class AssetsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    # Adds behaviors for hyrax-iiif_av plugin.
    include Hyrax::IiifAv::ControllerBehavior
    # Handle Child Work button and redirect to child work page
    include Hyrax::ChildWorkRedirect
    self.curation_concern_type = ::Asset

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::AssetPresenter
  end
end
