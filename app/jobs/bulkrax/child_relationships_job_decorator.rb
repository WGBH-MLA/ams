# frozen_string_literal: true

# OVERRIDE bulkrax v.1.0.0 to add a limit to the job rescheduling
# while forming relationships to child works that were found

module Bulkrax
  module ChildRelationshipsJobDecorator
    def perform(*args)
      @args = args

      if entry.factory_class == Collection
        collection_membership
      else
        work_membership
      end
      # Not all of the Works/Collections exist yet; reschedule
    rescue Bulkrax::ChildWorksError
      # OVERRIDE bulkrax v.1.0.0
      # In case the work hasn't been created, don't endlessly reschedule the job
      attempts = (args[3] || 0) + 1
      child_ids = @missing_entry_ids.presence || args[1]

      reschedule(args[0], child_ids, args[2], attempts) unless attempts > 5
    end

    def work_membership
      seen_count = 0
      child_entries.each do |child_entry|
        child_record = child_entry.factory.find
        next if child_record.blank? or child_record.is_a?(Collection)
        next if parent_record.ordered_members&.to_a&.include?(child_record)
        parent_record.ordered_members << child_record
        seen_count += 1
      end
      parent_record.save!
      raise ChildWorksError if seen_count < child_entries.count
    end

    def parent_record
      @parent_record ||= entry&.factory&.find
    end

    private

    # OVERRIDE bulkrax v.1.0.0
    # passing 4 args now
    def reschedule(entry_id, child_entry_ids, importer_run_id, attempts)
      ChildRelationshipsJob.set(wait: 10.minutes).perform_later(entry_id, child_entry_ids, importer_run_id, attempts)
    end
  end
end

::Bulkrax::ChildRelationshipsJob.prepend(Bulkrax::ChildRelationshipsJobDecorator)
