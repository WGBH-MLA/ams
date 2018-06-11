module Hyrax::AddParentIdToActor
  extend ActiveSupport::Concern

  def attributes_for_actor
    attributes = super
    if params.has_key?(:parent_id)
      attributes[:parent_id] = params[:parent_id]
    end
    attributes
  end
end
