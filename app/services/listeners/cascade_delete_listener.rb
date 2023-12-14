# frozen_string_literal: true

module Listeners
  class CascadeDeleteListener

    def on_object_deleted(event)
      resource = event.to_h.fetch(:object) { Hyrax.query_service.find_by(id: event[:object_id]) }
      return unless resource.is_a?(AssetResource) || resource.is_a?(PhysicalInstantiationResource) || resource.is_a?(DigitalInstantiationResource)
      resource.members.each do |member|
        Hyrax.index_adapter.delete(resource: member)
        Hyrax.persister.delete(resource: member)
      end
    end
  end
end
