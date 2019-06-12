module AMS
  class AAPBPBCoreZippedBatchIngestFixer
    attr_reader :batch

    def initialize(batch_id)
      @batch = Hyrax::BatchIngest::Batch.find(batch_id)
      raise ArgumentError, 'batch must be of type "aapb_pbcore_zipped"' unless @batch.ingest_type == 'aapb_pbcore_zipped'
    end

    def delete_parent_assets_of_failed_children
      parent_assets_of_failed_children.each { |asset| asset.destroy! }
    end

    delegate :batch_items, to: :batch

    private

      # For the AAPB PBCore Zipped XML batch ingest, the :id_within_batch for
      # each batch item is the unzipped PBCore XML file. This PBCore XML
      # contains one Asset and possible several children of that asset.
      # This method checks for failures among the child batch items, and if any
      # are found, it then fetches the parent Asset, which we want to delete,
      # because it has been only 'partially' ingested.
      def parent_assets_of_failed_children
        @parent_assets_of_failed_children ||= parent_asset_ids_for_failed_children.map { |asset_id| Asset.find asset_id }
      end

      def parent_asset_ids_for_failed_children

        @parent_asset_ids_for_failed_children ||= failed_batch_items_for_assets.map { |batch_item| batch_item.repo_object_id }
      end

      def failed_batch_items_for_assets
        @failed_batch_items_for_assets ||= failed_batch_item_groups.map do |failed_batch_item_group|
          failed_batch_item_group.select { |batch_item| batch_item.repo_object_class_name == 'Asset' }
        end.flatten.compact
      end

      def failed_batch_item_groups
        @failed_batch_item_groups ||= batch_item_groups.select do |batch_item_group|
          batch_item_group.any? { |batch_item| batch_item.status == 'failed' }
        end
      end

      def batch_item_groups
        @batch_item_groups ||= batch_items.group_by(&:id_within_batch).values
      end
  end
end
