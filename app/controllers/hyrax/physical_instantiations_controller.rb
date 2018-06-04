# Generated via
#  `rails generate hyrax:work PhysicalInstantiation`

module Hyrax
  class PhysicalInstantiationsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    # Handle Child Work button and redirect to child work page
    include Hyrax::ChildWorkRedirect
    self.curation_concern_type = ::PhysicalInstantiation

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::PhysicalInstantiationPresenter
  end
end
