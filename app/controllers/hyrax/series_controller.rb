# Generated via
#  `rails generate hyrax:work Series`

module Hyrax
  class SeriesController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Series

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::SeriesPresenter
  end
end
