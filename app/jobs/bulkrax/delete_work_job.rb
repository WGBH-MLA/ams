# frozen_string_literal: true

require_dependency Bulkrax::Engine.root.join('app', 'jobs', 'bulkrax', 'delete_work_job')

Bulkrax::DeleteWorkJob.class_eval do 
  # rubocop:disable Rails/SkipsModelValidations
  def perform(entry, importer_run)
    work = entry.factory.find
    if work.is_a? Asset
      asset_destroyer = AMS::AssetDestroyer.new
      asset_destroyer.destroy([work.id])
    end
    importer_run.increment!(:deleted_records)
    importer_run.decrement!(:enqueued_records)
  end
  # rubocop:enable Rails/SkipsModelValidations
end
