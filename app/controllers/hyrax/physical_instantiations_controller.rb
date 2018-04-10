# Generated via
#  `rails generate hyrax:work PhysicalInstantiation`

module Hyrax
  class PhysicalInstantiationsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::PhysicalInstantiation

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::PhysicalInstantiationPresenter
  end
end
