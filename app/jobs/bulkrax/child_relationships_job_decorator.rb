# frozen_string_literal: true

# OVERRIDE bulkrax v.1.0.0

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
      attempts = (args[3] || 0) + 1
      child_ids = @missing_entry_ids.presence || args[1]

      # In case the work hasn't been created, don't endlessly reschedule the job
      reschedule(args[0], child_ids, args[2], attempts) unless attempts > 5
    end

    def work_membership
      # add works to work
      members_works = []
      # reject any Collections, they can't be children of Works
      child_works_hash.each { |k, v| members_works << k if v[:class_name] != 'Collection' }
      if members_works.length < child_entries.length # rubocop:disable Style/IfUnlessModifier
        Rails.logger.warn("Cannot add collections as children of works: #{(@child_entries.length - members_works.length)} collections were discarded for parent entry #{@entry.id} (of #{@child_entries.length})")
      end
      work_parent_work_child(members_works) if members_works.present?
      # OVERRIDE bulkrax v.1.0.0
      raise ChildWorksError if @missing_entry_ids.present?
    end

    # OVERRIDE bulkrax v.1.0.0
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
  end
end

::Bulkrax::ChildRelationshipsJob.prepend(Bulkrax::ChildRelationshipsJobDecorator)
