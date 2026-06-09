# frozen_string_literal: true

require_dependency Bulkrax::Engine.root.join('app', 'jobs', 'bulkrax', 'delete_work_job')

Bulkrax::DeleteWorkJob.class_eval do 
  # rubocop:disable Rails/SkipsModelValidations
  def perform(entry, importer_run)
    work = entry.factory.find
    # Note: AssetDestroyer was removed during old model cleanup
    # AssetResource deletion is handled by the default Bulkrax behavior
    if work.is_a? AssetResource
      # TODO: Implement custom AssetResource deletion logic if needed
      work.destroy
    end
    importer_run.increment!(:deleted_records)
    importer_run.decrement!(:enqueued_records)
  end
  # rubocop:enable Rails/SkipsModelValidations
end
