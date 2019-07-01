require 'rails_helper'
require 'ams/aapb_pbcore_zipped_batch_ingest_expunger'

RSpec.describe AMS::AAPBPBCoreZippedBatchIngestExpunger do
  describe '.new' do
    context 'with the wrong kind of batch' do
      let(:wrong_kind_of_batch) { create(:batch, ingest_type: 'wrong') }
      it 'throws an ArgumentError' do
        expect { described_class.new(wrong_kind_of_batch.id) }.to raise_error ArgumentError, 'batch must be of type "aapb_pbcore_zipped"'
      end
    end
  end

  describe '#delete_parent_assets_of_failed_children' do
    # Create a batch for testing.
    let(:batch) { create(:batch, ingest_type: 'aapb_pbcore_zipped') }
    # Create a random list of assets.
    let(:assets) do
      rand(1..4).times.map { create(:asset, id: rand(999999)) }
    end
    # Pick one unlucky asset to have a child that failed to ingest.
    let(:asset_with_failed_child) { assets.sample }
    let(:asset_with_no_failing_children) { assets - [asset_with_failed_child] }

    before do
      # Setup a mock ingest. For each of the assets...
      assets.each do |asset|
        id_within_batch = "#{asset.id}.xml"
        # Create successful batch items for the assets.
        create(:batch_item, batch: batch, repo_object_class_name: 'Asset', repo_object_id: asset.id, status: 'completed', id_within_batch: id_within_batch)
        # Create a random number of successful batch items that share the
        # :id_within_batch for the asset.
        create_list(:batch_item, rand(4), batch: batch, repo_object_class_name: 'ChildObject', status: 'completed', id_within_batch: id_within_batch)
        # If this is the unlucky asset...
        if asset == asset_with_failed_child
          # Create a failed batch item that shares the same :id_within_batch
          # with the asset.
          create(:batch_item, batch: batch, repo_object_class_name: 'ChildObject', status: 'failed', id_within_batch: id_within_batch)
        end

        allow(Asset).to receive(:find).with(asset.id).and_return(asset)
        allow(asset).to receive(:destroy!).and_return(nil)
      end

      # Run the method under test.
      described_class.new(batch.id).delete_parent_assets_of_failed_children
    end

    it 'deletes parent Assets of failed batch items' do
      expect(asset_with_failed_child).to have_received(:destroy!)
    end

    it 'does not delete parent Asset where all children were successfully ingested' do
      asset_with_no_failing_children.each do |asset|
        expect(asset).to_not have_received(:destroy!)
      end
    end
  end
end
