require 'rails_helper'
require 'ams/aapb_pbcore_zipped_batch_ingest_failure_finder'

RSpec.describe AMS::AAPBPBCoreZippedBatchIngestFailureFinder do

  describe '.find_failures' do
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

        if asset == asset_with_failed_child
         # Create failed batch items for the asset_with_failed_child.
            create(:batch_item, batch: batch, repo_object_class_name: 'Asset', repo_object_id: asset.id, status: 'failed', id_within_batch: id_within_batch)
        else
          # Create successful batch items for the assets.
          create(:batch_item, batch: batch, repo_object_class_name: 'Asset', repo_object_id: asset.id, status: 'completed', id_within_batch: id_within_batch)
        end

        allow(Asset).to receive(:find).with(asset.id).and_return(asset)
      end
    end

    it 'returns the id_within_batch of failed Asset' do
      expect(described_class.find_failures).to include("#{asset_with_failed_child.id}.xml")
    end
  end
end
