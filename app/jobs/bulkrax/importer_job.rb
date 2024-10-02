# frozen_string_literal: true
# OVERRIDE Bulkrax 1.0.2 to rescue errors

require_dependency Bulkrax::Engine.root.join('app', 'jobs', 'bulkrax', 'importer_job').to_s

Bulkrax::ImporterJob.class_eval do
  def perform(importer_id, only_updates_since_last_import = false)
    importer = Bulkrax::Importer.find(importer_id)

    importer.current_run
    unzip_imported_file(importer.parser)
    import(importer, only_updates_since_last_import)
    update_current_run_counters(importer)
    schedule(importer) if importer.schedulable?
  rescue RuntimeError => e
    # Quits job when xml format is invalid
    Rails.logger.error "#{e.class}: #{e.message}\n\nBacktrace:\n#{e.backtrace.join("\n")}"
    nil
  end

  def import(importer, only_updates_since_last_import)
    importer.only_updates = only_updates_since_last_import || false
    return unless importer.valid_import?
    importer.import_collections
    importer.import_works
    importer.create_parent_child_relationships unless importer.validate_only
  end
end
