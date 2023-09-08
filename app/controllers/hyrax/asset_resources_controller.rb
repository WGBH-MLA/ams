# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource AssetResource`
module Hyrax
  # Generated controller for AssetResource
  class AssetResourcesController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::AssetResource
    # Handle Child Work button and redirect to child work page
    include Hyrax::ChildWorkRedirect

    # Use a Valkyrie aware form service to generate Valkyrie::ChangeSet style
    # forms.
    self.work_form_service = Hyrax::FormFactory.new
    self.show_presenter = AssetResourcePresenter
  end
end
