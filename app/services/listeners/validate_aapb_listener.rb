# frozen_string_literal: true

module Listeners
  class ValidateAapbListener

    # currently not called directly
    def on_object_membership_updated(event)
      resource = event.to_h.fetch(:object) { Hyrax.query_service.find_by(id: event[:object_id]) }
      return unless resource?(resource)

      invalid_messages = []
      case resource
      when EssenceTrackResource
        invalid_messages << resource.aapb_invalid_message unless resource.aapb_valid?
        instantiation_resource = Hyrax.query_service.custom_queries.find_parent_work(resource: resource)
        invalid_messages << instantiation_resource.aapb_invalid_message if instantiation_resource && !instantiation_resource.aapb_valid?
        parent_resource = Hyrax.query_service.custom_queries.find_parent_work(resource: instantiation_resource) if instantiation_resource
      when PhysicalInstantiationResource, DigitalInstantiationResource
        invalid_messages << resource.aapb_invalid_message unless resource.aapb_valid?
        parent_resource = Hyrax.query_service.custom_queries.find_parent_work(resource: resource)
      when AssetResource
        parent_resource = resource
      else
        return
      end

      return unless parent_resource.present?
      parent_resource.set_validation_status(invalid_messages)
      # we save and index the parent here and do not publish an event so as not to create a loop
      # or save the same asset_resource multiple times per save
      Hyrax.persister.save(resource: parent_resource)
      Hyrax.index_adapter.save(resource: parent_resource)
    rescue Valkyrie::Persistence::ObjectNotFoundError => err
      Hyrax.logger.error("Tried to index for an #{event.id} event with " \
        "payload #{event.payload}, but failed due to error:\n"\
        "\t#{err.message}")
    end

    def on_object_metadata_updated(event)
      on_object_membership_updated(event)
    end

    def on_object_deleted(event)
      on_object_membership_updated(event)
    end

    private

    def resource?(resource)
      return true if resource.is_a? Valkyrie::Resource
      log_non_resource(resource)
      false
    end

    def log_non_resource(resource)
      generic_type = resource_generic_type(resource)
      Hyrax.logger.info("Skipping #{generic_type} reindex because the " \
        "#{generic_type} #{resource} was not a Valkyrie::Resource.")
    end

    def resource_generic_type(resource)
      resource.try(:collection?) ? 'collection' : 'object'
    end
  end
end
