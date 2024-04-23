# frozen_string_literal: true

module Listeners
  class CascadeDeleteListener

    def on_object_deleted(event)
      resource = event.to_h.fetch(:object) { Hyrax.query_service.find_by(id: event[:object_id]) }
      return unless resource.is_a?(AssetResource) || resource.is_a?(PhysicalInstantiationResource) || resource.is_a?(DigitalInstantiationResource)
      resource.members.each do |member|
        Hyrax::Transactions::Container['work_resource.destroy']
          .with_step_args('work_resource.delete' => { user: event[:user] },
                          'work_resource.delete_all_file_sets' => { user: event[:user] })
          .call(member).value!
      end
    end
  end
end
