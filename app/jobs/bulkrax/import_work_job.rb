# frozen_string_literal: true
# OVERRIDE: Bulkrax 1.0.1 to retry Ldp::NotFound and to limit retries to 3
module Bulkrax
  class ImportWorkJob < ApplicationJob
    queue_as :import

    # rubocop:disable Rails/SkipsModelValidations
    def perform(entry_id, run_id, time_to_live = 3, *)
      entry = Entry.find(entry_id)
      importer_run = ImporterRun.find(run_id)
      entry.build
      if entry.status == "Complete"
        ImporterRun.find(run_id).increment!(:processed_records)
        ImporterRun.find(run_id).decrement!(:enqueued_records) unless ImporterRun.find(run_id).enqueued_records <= 0 # rubocop:disable Style/IdenticalConditionalBranches
      else
        # do not retry here because whatever parse error kept you from creating a work will likely
        # keep preventing you from doing so.
        ImporterRun.find(run_id).increment!(:failed_records)
        ImporterRun.find(run_id).decrement!(:enqueued_records) unless ImporterRun.find(run_id).enqueued_records <= 0 # rubocop:disable Style/IdenticalConditionalBranches
      end
      # Regardless of completion or not, we want to decrement the enqueued records.
      importer_run.decrement!(:enqueued_records) unless importer_run.enqueued_records <= 0

      entry.save!
      entry.importer.current_run = importer_run
      entry.importer.record_status
    rescue Bulkrax::CollectionsCreatedError, Ldp::NotFound => e
      Rails.logger.warn("#{self.class} entry_id: #{entry_id}, run_id: #{run_id} encountered #{e.class}: #{e.message}")
      # You get 3 attempts at the above perform before we have the import exception cascade into
      # the Sidekiq retry ecosystem.
      # rubocop:disable Style/IfUnlessModifier
      if time_to_live <= 1
        raise "Exhausted reschedule limit for #{self.class} entry_id: #{entry_id}, run_id: #{run_id}.  Attemping retries"
      end
      # rubocop:enable Style/IfUnlessModifier
      reschedule(entry_id, run_id, time_to_live)
    end
    # rubocop:enable Rails/SkipsModelValidations

    def reschedule(entry_id, run_id, time_to_live)
      ImportWorkJob.set(wait: 1.minute).perform_later(entry_id, run_id, time_to_live - 1)
    end
  end
end
