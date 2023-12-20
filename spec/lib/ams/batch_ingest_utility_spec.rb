require 'rails_helper'
require 'ams/batch_ingest_utility'

RSpec.describe AMS::BatchIngestUtility do

  # Create a batch for testing.
  let!(:batch) { create(:batch) }
  # Create 2 sets of objects, one that we will mark as needing re-ingest, and
  # another that will not need re-ingest.
  let!(:objects_needing_reingest)  { 3.times.map { AssetResource.create } }
  let!(:objects_not_needing_reingest) { 3.times.map { AssetResource.create } }

  let!(:batch_items) do
    # For all the repo objects, create a completed batch item. Use 2 different
    # values for id_within_batch to distinguish between those that will need
    # re-ingesting and those that will not.
    items = (objects_needing_reingest + objects_not_needing_reingest).map do |obj|
      id_within_batch = objects_needing_reingest.include?(obj) ? 'bad_source_data.xml' : 'good_source_data.xml'
      create(:batch_item, batch: batch, repo_object_class_name: 'DoesNotMatter', repo_object_id: obj.id, status: 'completed', id_within_batch: id_within_batch)
    end
    # Create the batch item that failed, and thus marking all other batch items
    # that share the same id_within_batch as needing to be re-ingested.
    items << create(:batch_item, batch: batch, repo_object_class_name: 'DoesNotMatter', repo_object_id: nil, status: 'failed', id_within_batch: 'bad_source_data.xml')
  end

  # The object under test.
  let!(:batch_ingest_utility) { described_class.new(batch.id) }

  describe '#ids_within_batch_needing_reingest' do
    it 'returns the id_within_batch values for batch items that need reingested' do
      expect(batch_ingest_utility.ids_within_batch_needing_reingest).to eq ['bad_source_data.xml']
    end
  end

  describe '#delete_objects_of_batch_items_needing_reingest' do
    before { batch_ingest_utility.delete_objects_of_batch_items_needing_reingest }

    it 'deletes objects needing to be reingested' do
      objects_needing_reingest.each do |obj|
        expect(obj.id).to_not exist_in_repository
      end
    end

    it 'does not delete objects that do not need reingested' do
      objects_not_needing_reingest.each do |obj|
        expect(obj.id).to exist_in_repository
      end
    end
  end
end
