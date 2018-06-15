# Generated via
#  `rails generate hyrax:work Contribution`

module Hyrax
  class ContributionsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    # Handle Child Work button and redirect to child work page
    include Hyrax::ChildWorkRedirect
    # Redirects away from controller#new if object does not have parent_id
    include Hyrax::RedirectNewAction

    self.curation_concern_type = ::Contribution

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::ContributionPresenter
  end
end
