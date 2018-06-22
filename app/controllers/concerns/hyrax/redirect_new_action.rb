module Hyrax::RedirectNewAction
  extend ActiveSupport::Concern

  def new
    attributes = super
    redirect_to my_works_path, alert: "#{attributes.model.model_name.human.titleize} must be created from an Asset." unless params[:parent_id].present?
  end
end
