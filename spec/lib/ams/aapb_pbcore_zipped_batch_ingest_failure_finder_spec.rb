require 'rails_helper'
require 'ams/aapb_pbcore_zipped_batch_ingest_failure_finder'

RSpec.describe AMS::AAPBPBCoreZippedBatchIngestFailureFinder do

  # Create a batches for testing.
  let(:batch_with_failure) { create(:batch, ingest_type: 'aapb_pbcore_zipped') }
  let(:batch_without_failure) { create(:batch, ingest_type: 'aapb_pbcore_zipped') }
  let(:batch_with_expunged) { create(:batch, ingest_type: 'aapb_pbcore_zipped') }

  # Create a list assets that will have a failure.
  let(:assets_with_failure) do
    rand(3..5).times.map { create(:asset, id: rand(999999)) }
  end
  # Pick one unlucky asset to fail.
  let(:failed_asset) { assets_with_failure.first }

  # Create a list assets that won't have a failure.
  let(:assets_without_failure) do
    rand(3..5).times.map { create(:asset, id: rand(999999)) }
  end

  # Create a list of assets that will have an expunged asset.
  let(:assets_with_expunged) do
    rand(3..5).times.map { create(:asset, id: rand(999999)) }
  end

  # Pick one unlucky asset to have been expunged.
  let(:expunged_asset) { assets_with_expunged.first }

  def create_batch_item(batch, asset, status)
    create(:batch_item, batch: batch, repo_object_class_name: 'Asset', repo_object_id: asset.id, status: status, id_within_batch: "#{asset.id}.xml")
  end

  describe '.find_batches_with_failures' do
    # Setup mock ingests.
    before do
      assets_with_failure.each do |asset|
        if asset == failed_asset
         # Create failed batch item for the failed_asset.
          create_batch_item(batch_with_failure, asset, 'failed')
        else
          # Create successful batch items for the assets.
          create_batch_item(batch_with_failure, asset, 'completed')
        end
      end

      assets_without_failure.each do |asset|
        create_batch_item(batch_without_failure, asset, 'completed')
      end
    end

    it 'returns the batch_id of the batch with a failed Asset' do
      expect(described_class.find_batches_with_failures.length).to eq(1)
      expect(described_class.find_batches_with_failures).to include(batch_with_failure.id)
      expect(described_class.find_batches_with_failures).not_to include(batch_without_failure.id)
    end
  end

  describe '.find_xml_files_for_reingest' do
    # Setup mock ingests.
    before do
      assets_with_expunged.each do |asset|
        if asset == expunged_asset
          create_batch_item(batch_with_expunged, asset, 'expunged')
        else
          create_batch_item(batch_with_expunged, asset, 'completed')
        end
      end

      assets_without_failure.each do |asset|
        create_batch_item(batch_without_failure, asset, 'completed')
      end
    end

    it 'returns the id_within_batch of batch items that have been expunged' do
      expect(described_class.find_xml_files_for_reingest.length).to eq(1)
      expect(described_class.find_xml_files_for_reingest).to include("#{expunged_asset.id}.xml")
      expect(described_class.find_xml_files_for_reingest).not_to include("#{assets_without_failure.sample.id}.xml")
    end
  end
end
