module AMS
  class BatchIngestUtility
    attr_reader :batch
    delegate :batch_items, to: :batch
    delegate :repo_object_for, to: :class

    def initialize(batch_id)
      @batch = Hyrax::BatchIngest::Batch.find(batch_id)
    end

    # For each batch item within the incomplete batch item groups, delete the
    # object to which it refers, and delete the repo_object_id of the batch
    # item.
    def delete_objects_of_batch_items_needing_reingest
      batch_items_needing_reingest.each do |batch_item|
        repo_object = begin
                        ActiveFedora::Base.find batch_item.repo_object_id
                      rescue
                        nil
                      end
        repo_object&.destroy!
        batch_item.repo_object_id = nil
        batch_item.save!
      end
    end

    # The id_within_batch of the incomplete bach items identifies what needs to
    # be reingested.
    def ids_within_batch_needing_reingest
      batch_items_needing_reingest.flatten.map(&:id_within_batch).uniq
    end

    private

      # An incomplete batch item group is a group of batch items where at least
      # one has failed.
      def batch_items_needing_reingest
        @batch_items_needing_reingest ||= batch_item_groups.select do |batch_item_group|
          batch_item_group.any? { |batch_item| batch_item.status == 'failed' }
        end.flatten
      end

      # A batch item group is a group of batch items all having the same value
      # for :id_within_batch, meaning they all came from the same source data.
      def batch_item_groups
        @batch_item_groups ||= batch_items.group_by(&:id_within_batch).values
      end

    class << self
      def repo_object_for(batch_item)
        # if batch_item is an ID, look up the BatchItem instance.
        batch_item = Hyrax::BatchIngest::BatchItem.find(batch_item) unless batch_item.is_a? Hyrax::BatchIngest::BatchItem
        ActiveFedora::Base.find batch_item.repo_object_id
      rescue
        nil
      end
    end
  end
end


# TODO: path batch ingest gem to include BatchItem#'expunged' status
