require 'rails_helper'
require 'ams/aapb_pbcore_zipped_batch_ingest_failure_finder'

RSpec.describe AMS::AAPBPBCoreZippedBatchIngestFailureFinder do

  describe '.find_failures' do
    # Create a batch for testing.
    let(:batch) { create(:batch, ingest_type: 'aapb_pbcore_zipped') }
    # Create a random list of assets.
    let(:assets) do
      rand(3..5).times.map { create(:asset, id: rand(999999)) }
    end
    # Pick one unlucky asset to have a child that failed to ingest.
    let(:failed_asset) { assets.first }
    let(:successful_assets) { assets - [failed_asset] }

    before do
      # Setup a mock ingest. For each of the assets...
      assets.each do |asset|
        id_within_batch = "#{asset.id}.xml"

        if asset == failed_asset
         # Create failed batch item for the failed_asset.
            create(:batch_item, batch: batch, repo_object_class_name: 'Asset', repo_object_id: asset.id, status: 'failed', id_within_batch: id_within_batch)
        else
          # Create successful batch items for the assets.
          create(:batch_item, batch: batch, repo_object_class_name: 'Asset', repo_object_id: asset.id, status: 'completed', id_within_batch: id_within_batch)
        end
      end
    end

    it 'returns the id_within_batch of failed Asset' do
      expect(described_class.find_failures.length).to eq(1)
      expect(described_class.find_failures).to include("#{failed_asset.id}.xml")
    end

    it 'does not return the id_within_batch of the successful Assets' do
      successful_assets.each do |asset|
        expect(described_class.find_failures).not_to include("#{asset.id}.xml")
      end
    end

    context 'on an expunged Asset' do
      let(:expunged_asset) { successful_assets.sample }

      before do
        expunged_asset_batch_item = Hyrax::BatchIngest::BatchItem.where(:repo_object_id => expunged_asset.id).first
        expunged_asset_batch_item.status = 'expunged'
        expunged_asset_batch_item.save!
      end

      it 'returns the id_within_batch of the expunged Asset' do
        expect(described_class.find_failures.length).to eq(2)
        expect(described_class.find_failures).to include("#{expunged_asset.id}.xml")
      end
    end
  end
end
