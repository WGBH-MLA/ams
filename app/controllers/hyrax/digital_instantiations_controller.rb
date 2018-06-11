# Generated via
#  `rails generate hyrax:work DigitalInstantiation`

module Hyrax
  class DigitalInstantiationsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    # Add after WorksControllerBehavior to override method
    include Hyrax::AddParentIdToActor
    include Hyrax::BreadcrumbsForWorks
    # Handle Child Work button and redirect to child work page
    include Hyrax::ChildWorkRedirect
    self.curation_concern_type = ::DigitalInstantiation

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::DigitalInstantiationPresenter
  end
end
