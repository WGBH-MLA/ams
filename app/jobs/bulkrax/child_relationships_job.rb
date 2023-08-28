# frozen_string_literal: true

# OVERRIDE: a modified version of the job from Bulkrax v1.0.0
#     - adds attempts parameter to prevent endless reschedules
#     - overrides method work_membership
module Bulkrax
  class ChildWorksError < RuntimeError; end
  class ChildRelationshipsJob < ApplicationJob
    queue_as :import

    def perform(*args)
      @args = args

      if entry.factory_class == Collection
        collection_membership
      else
        work_membership
      end

    rescue Bulkrax::ChildWorksError
      # Not all of the Works/Collections exist yet; reschedule
      # In case the work hasn't been created, don't endlessly reschedule the job
      attempts = (args[3] || 0) + 1
      child_ids = @missing_entry_ids.presence || args[1]

      reschedule(args[0], child_ids, args[2], attempts) unless attempts > 5
    end

    def collection_membership
      # add collection to works
      member_of_collection = []
      child_works_hash.each { |k, v| member_of_collection << k if v[:class_name] != 'Collection' }
      member_of_collection.each { |work| work_child_collection_parent(work) }

      # add collections to collection
      members_collections = []
      child_works_hash.each { |k, v| members_collections << k if v[:class_name] == 'Collection' }
      collection_parent_collection_child(members_collections) if members_collections.present?
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

    def entry
      @entry ||= Bulkrax::Entry.find(@args[0])
    end

    def parent_record
      @parent_record ||= entry&.factory&.find
    end

    def child_entries
      @child_entries ||= @args[1].map { |e| Bulkrax::Entry.find(e) }
    end

    def child_works_hash
      @child_works_hash ||= child_entries.each_with_object({}) do |child_entry, hash|
        work = child_entry.factory.find
        # If we can't find the Work/Collection, raise a custom error
        raise ChildWorksError if work.blank?
        hash[work.id] = { class_name: work.class.to_s, entry.parser.source_identifier => child_entry.identifier }
      end
    end

    def importer_run_id
      @args[2]
    end

    def user
      @user ||= entry.importerexporter.user
    end

    private

    # rubocop:disable Rails/SkipsModelValidations
    # Work-Collection membership is added to the child as member_of_collection_ids
    # This is adding the reverse relatinship, from the child to the parent
    def work_child_collection_parent(work_id)
      attrs = { id: work_id, collections: [{ id: entry&.factory&.find&.id }] }
      Bulkrax::ObjectFactory.new(attributes: attrs,
                                 source_identifier_value: child_works_hash[work_id][entry.parser.source_identifier],
                                 work_identifier: entry.parser.work_identifier,
                                 replace_files: false,
                                 user: user,
                                 klass: child_works_hash[work_id][:class_name].constantize).run
      ImporterRun.find(importer_run_id).increment!(:processed_children)
    rescue StandardError => e
      entry.status_info(e)
      ImporterRun.find(importer_run_id).increment!(:failed_children)
    end

    # Collection-Collection membership is added to the as member_ids
    def collection_parent_collection_child(member_ids)
      attrs = { id: entry&.factory&.find&.id, children: member_ids }
      Bulkrax::ObjectFactory.new(attributes: attrs,
                                 source_identifier_value: entry.identifier,
                                 work_identifier: entry.parser.work_identifier,
                                 replace_files: false,
                                 user: user,
                                 klass: entry.factory_class).run
      ImporterRun.find(importer_run_id).increment!(:processed_children)
    rescue StandardError => e
      entry.status_info(e)
      ImporterRun.find(importer_run_id).increment!(:failed_children)
    end

    # Work-Work membership is added to the parent as member_ids
    def work_parent_work_child(member_ids)
      # build work_members_attributes
      attrs = { id: entry&.factory&.find&.id,
                work_members_attributes: member_ids.each.with_index.each_with_object({}) do |(member, index), ids|
                  ids[index] = { id: member }
                end }
      Bulkrax::ObjectFactory.new(attributes: attrs,
                                 source_identifier_value: entry.identifier,
                                 work_identifier: entry.parser.work_identifier,
                                 replace_files: false,
                                 user: user,
                                 klass: entry.factory_class).run
      ImporterRun.find(importer_run_id).increment!(:processed_children)
    rescue StandardError => e
      entry.status_info(e)
      ImporterRun.find(importer_run_id).increment!(:failed_children)
    end
    # rubocop:enable Rails/SkipsModelValidations

    def reschedule(entry_id, child_entry_ids, importer_run_id, attempts)
      ChildRelationshipsJob.set(wait: 10.minutes).perform_later(entry_id, child_entry_ids, importer_run_id, attempts)
    end
  end
end
