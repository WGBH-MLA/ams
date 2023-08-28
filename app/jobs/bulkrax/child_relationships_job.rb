# frozen_string_literal: true

module Bulkrax
  class ChildWorksError < RuntimeError; end
  class ChildRelationshipsJob < ApplicationJob
    include DynamicRecordLookup

    queue_as :import

    def perform(parent_id: parent_id, child_entry_ids: child_entry_ids, importer_run_id: current_run.id, args: {})
      @parent_id = parent_id
      @child_entry_ids = child_entry_ids
      @importer_run_id = importer_run_id

      if entry.factory_class == Collection
        collection_membership
      else
        work_membership
      end

      @parent_record = entry.parser.work_identifier

      # Not all of the Works/Collections exist yet; reschedule
    rescue Bulkrax::ChildWorksError
      reschedule(args[0], args[1], args[2])
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
      # add works to work
      # reject any Collections, they can't be children of Works
      members_works = []
      # reject any Collections, they can't be children of Works
      child_works_hash.each { |k, v| members_works << k if v[:class_name] != 'Collection' }
      if members_works.length < child_entries.length # rubocop:disable Style/IfUnlessModifier
        Rails.logger.warn("Cannot add collections as children of works: #{(@child_entries.length - members_works.length)} collections were discarded for parent entry #{@entry.id} (of #{@child_entries.length})")
      end
      work_parent_work_child(members_works) if members_works.present?
    end

    def entry
      @entry ||= Bulkrax::Entry.find(@parent_id)
    end

    def child_entries
      @child_entries ||= @child_entry_ids.map { |e| Bulkrax::Entry.find(e) }
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
      @importer_run_id
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
                                 collection_field_mapping: entry.parser.collection_field_mapping,
                                 replace_files: false,
                                 user: user,
                                 klass: child_works_hash[work_id][:class_name].constantize).run
      ImporterRun.find(importer_run_id).increment!(:processed_relationships)
    rescue StandardError => e
      entry.status_info(e)
      ImporterRun.find(importer_run_id).increment!(:failed_relationships)
    end

    # Collection-Collection membership is added to the as member_ids
    def collection_parent_collection_child(member_ids)
      attrs = { id: entry&.factory&.find&.id, children: member_ids }
      Bulkrax::ObjectFactory.new(attributes: attrs,
                                 source_identifier_value: entry.identifier,
                                 work_identifier: entry.parser.work_identifier,
                                 collection_field_mapping: entry.parser.collection_field_mapping,
                                 replace_files: false,
                                 user: user,
                                 klass: entry.factory_class).run
      ImporterRun.find(importer_run_id).increment!(:processed_relationships)
    rescue StandardError => e
      entry.status_info(e)
      ImporterRun.find(importer_run_id).increment!(:failed_relationships)
    end

    # Work-Work membership is added to the parent as member_ids
    def work_parent_work_child(member_ids)
      # build work_members_attributes
      # attrs = { id: entry&.factory&.find&.id,
      #           work_members_attributes: member_ids.each.with_index.each_with_object({}) do |(member, index), ids|
      #             ids[index] = { id: member }
      #           end }

      # this calls actor stack, skip this and do the work here instead
      # Bulkrax::ObjectFactory.new(attributes: attrs,
      #                            source_identifier_value: entry.identifier,
      #                            work_identifier: entry.parser.work_identifier,
      #                            collection_field_mapping: entry.parser.collection_field_mapping,
      #                            replace_files: false,
      #                            user: user,
      #                            klass: entry.factory_class).run

      member_ids.each do |child_record|
        add_to_work(child_record, @parent_record)
      end

      # add_to_work(member)

      ImporterRun.find(importer_run_id).increment!(:processed_relationships)
    rescue StandardError => e
      entry.status_info(e)
      ImporterRun.find(importer_run_id).increment!(:failed_relationships)
    end
    # rubocop:enable Rails/SkipsModelValidations

    def add_to_work(child_record, parent_record)
      return true if parent_record.ordered_members.to_a.include?(child_record)

      parent_record.ordered_members << child_record
      @parent_record_members_added = true
      @child_members_added << child_record
    end

    def reschedule(entry_id, child_entry_ids, importer_run_id)
      ChildRelationshipsJob.set(wait: 10.minutes).perform_later(entry_id, child_entry_ids, importer_run_id)
    end

    private

    ##
    # We can use Hyrax's lock manager when we have one available.
    if defined?(::Hyrax)
      include Hyrax::Lockable

      def conditionally_acquire_lock_for(*args, &block)
        if Bulkrax.use_locking?
          acquire_lock_for(*args, &block)
        else
          yield
        end
      end
    else
      # Otherwise, we're providing no meaningful lock manager at this time.
      def acquire_lock_for(*)
        yield
      end

      alias conditionally_acquire_lock_for acquire_lock_for
    end
  end
end


# ::Bulkrax::ChildRelationshipsJob.prepend(Bulkrax::ChildRelationshipsJobDecorator) #if App.rails_5_1?
