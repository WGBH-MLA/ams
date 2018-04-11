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

    def update
      # TODO: where should this really go?
      Hyrax::CurationConcern.actor_factory.swap Hyrax::Actors::AttachMembersActor, Hyrax::Actors::AddAssetsToSeriesActor
      super
    end
  end
end
