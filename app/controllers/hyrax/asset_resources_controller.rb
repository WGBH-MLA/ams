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

    before_action :convert_blank_floats_to_nil, only: [:create, :update]


    private
    # This extends functionality from
    # Hyrax::WorksControllerBehavior#additional_response_formats, adding a
    # response for a ".xml" extension, returning the PBCore XML.
    def additional_response_formats(format)
      format.xml { render(plain: presenter.solr_document.export_as_pbcore) }
      super
    end


    # Removes blank start_time and end_time values from the contributors hash in the params.
    # This is necessary because the form allows for empty values, but the model expects these fields to be either a valid float or nil.
    def convert_blank_floats_to_nil
      params.fetch("asset_resource", {})
            .fetch("contributors", []).each do |contrib|
              contrib["start_time"] = nil if contrib.fetch("start_time", "").blank?
              contrib["end_time"] = nil if contrib.fetch("end_time", "").blank?
            end
    end
  end
end
