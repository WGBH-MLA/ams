# Generated via
#  `rails generate hyrax:work PhysicalInstantiation`

module Hyrax
  class PhysicalInstantiationsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    # Handle Child Work button and redirect to child work page
    include Hyrax::ChildWorkRedirect
    # Redirects away from controller#new if object does not have parent_id
    include Hyrax::RedirectNewAction

    self.curation_concern_type = ::PhysicalInstantiation

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::PhysicalInstantiationPresenter
  end
  
  def destroy
    if current_user.can? :destroy, PhysicalInstantiation
      super
    else
      flash[:error] = 'You are not permitted to do that!'
      redirect_to request.path
    end
  end
end
