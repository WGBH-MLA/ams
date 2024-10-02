# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource EssenceTrackResource`
module Hyrax
  # Generated controller for EssenceTrackResource
  class EssenceTrackResourcesController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    # Handle Child Work button and redirect to child work page
    include Hyrax::ChildWorkRedirect
    # Redirects away from controller#new if object does not have parent_id
    include Hyrax::RedirectNewAction

    self.curation_concern_type = ::EssenceTrackResource

    # Use a Valkyrie aware form service to generate Valkyrie::ChangeSet style
    # forms.
    self.work_form_service = Hyrax::FormFactory.new
    self.show_presenter = EssenceTrackResourcePresenter
  end
end
