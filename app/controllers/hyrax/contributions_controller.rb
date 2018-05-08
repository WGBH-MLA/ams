# Generated via
#  `rails generate hyrax:work Contribution`

module Hyrax
  class ContributionsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Contribution

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::ContributionPresenter
  end
end
