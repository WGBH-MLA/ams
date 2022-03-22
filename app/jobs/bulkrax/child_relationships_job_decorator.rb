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
      members_works = []
      # reject any Collections, they can't be children of Works
      child_works_hash.each { |k, v| members_works << k if v[:class_name] != 'Collection' }
      if members_works.length < child_entries.length # rubocop:disable Style/IfUnlessModifier
        Rails.logger.warn("Cannot add collections as children of works: #{(@child_entries.length - members_works.length)} collections were discarded for parent entry #{@entry.id} (of #{@child_entries.length})")
      end
      work_parent_work_child(members_works) if members_works.present?
      # OVERRIDE bulkrax v.1.0.0
      # reschedule the job only with works that don't exist yet
      raise ChildWorksError if @missing_entry_ids.present?
    end

    # OVERRIDE bulkrax v.1.0.0
    # don't stop all child relationships from being formed just because some child works don't exist
    def child_works_hash
      @missing_entry_ids = []

      @child_works_hash ||= child_entries.each_with_object({}) do |child_entry, hash|
        work = child_entry.factory.find

        if work.blank?
          @missing_entry_ids << child_entry.id
          next
        end

        hash[work.id] = { class_name: work.class.to_s, entry.parser.source_identifier => child_entry.identifier }
      end
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
