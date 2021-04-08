require 'rails_helper'
require 'pbcore'
require 'ams/migrations/audit/ams2_asset'

RSpec.describe AMS::Migrations::Audit::AMS2Asset, reset_data: false do

  # Use instance variable instead of `let` to avoid unnecessary IO.
  before :all { @asset = create(:asset, :family) }

  let(:solr_document) { SolrDocument.new(@asset.to_solr) }
  let(:ams2_asset) { described_class.new(solr_document: solr_document) }

  context 'with an invalid solr document' do
    let(:solr_document) { "not a SolrDocument" }
    describe '.new' do
      it 'raises an error' do
        expect { ams2_asset }.to raise_error, ArgumentError
      end
    end
  end

  context 'with a valid AMS 2 SolrDocument' do
    describe '#solr_document' do
      it 'returns the correct SolrDocument' do
        expect(ams2_asset.solr_document).to eq solr_document
      end
    end

    describe '#digital_instantiations_count' do
      let(:expected_count) { @asset.all_members(only: DigitalInstantiation).count }
      it 'returns the number of digital instantiations' do
        expect(ams2_asset.digital_instantiations_count).to eq expected_count
      end
    end

    describe '#physical_instantiations_count' do
      let(:expected_count) { @asset.all_members(only: PhysicalInstantiation).count }
      it 'returns the number of physical instantiations' do
        expect(ams2_asset.physical_instantiations_count).to eq expected_count
      end
    end

    describe '#essence_tracks_count' do
      let(:expected_count) { @asset.all_members(only: EssenceTrack).count }
      it 'returns the number of essence tracks' do
        expect(ams2_asset.essence_tracks_count).to eq expected_count
      end
    end
  end
end
