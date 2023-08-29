# frozen_string_literal: true
unless App.rails_5_1?
  
  # Generated via
  #  `rails generate hyrax:work_resource PhysicalInstantiationResource`
  module Hyrax
    # Generated controller for PhysicalInstantiationResource
    class PhysicalInstantiationResourcesController < ApplicationController
      # Adds Hyrax behaviors to the controller.
      include Hyrax::WorksControllerBehavior
      include Hyrax::BreadcrumbsForWorks
      self.curation_concern_type = ::PhysicalInstantiationResource
  
      # Use a Valkyrie aware form service to generate Valkyrie::ChangeSet style
      # forms.
      self.work_form_service = Hyrax::FormFactory.new
    end
  end
end
