# frozen_string_literal: true
unless App.rails_5_1?
  
  # Generated via
  #  `rails generate hyrax:work_resource DigitalInstantiationResource`
  module Hyrax
    # Generated controller for DigitalInstantiationResource
    class DigitalInstantiationResourcesController < ApplicationController
      # Adds Hyrax behaviors to the controller.
      include Hyrax::WorksControllerBehavior
      include Hyrax::BreadcrumbsForWorks
      self.curation_concern_type = ::DigitalInstantiationResource
  
      # Use a Valkyrie aware form service to generate Valkyrie::ChangeSet style
      # forms.
      self.work_form_service = Hyrax::FormFactory.new
    end
  end
end
