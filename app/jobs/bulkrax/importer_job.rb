# frozen_string_literal: true
# OVERRIDE Bulkrax 1.0.2 to rescue errors (and to add queued indexing if App.rails_5_1?)

require_dependency Bulkrax::Engine.root.join('app', 'jobs', 'bulkrax', 'importer_job').to_s

Bulkrax::ImporterJob.class_eval do
  def perform(importer_id, only_updates_since_last_import = false)
    importer = Bulkrax::Importer.find(importer_id)

    importer.current_run
    unzip_imported_file(importer.parser)
    import(importer, only_updates_since_last_import)
    update_current_run_counters(importer)
    schedule(importer) if importer.schedulable?
    # OVERRIDE Bulkrax 1.0.2 to add queued indexing if App.rails_5_1?
    # TODO: delete with dual boot cleanup - nested indexing is replaced by graph indexer
    Bulkrax::IndexAfterJob.set(wait: 1.minute).perform_later(importer) if App.rails_5_1?
  rescue RuntimeError => e
    # Quits job when xml format is invalid
    Rails.logger.error "#{e.class}: #{e.message}\n\nBacktrace:\n#{e.backtrace.join("\n")}"
    nil
  end
end
