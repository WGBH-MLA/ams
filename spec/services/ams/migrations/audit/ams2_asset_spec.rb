require 'rails_helper'
require 'pbcore'
require 'ams/migrations/audit/ams2_asset'

RSpec.describe AMS::Migrations::Audit::AMS2Asset do

  let(:asset) { create(:asset, :with_two_digital_instantiations_and_essence_tracks) }
  let(:solr_document) { SolrDocument.find(asset.id) }

  context 'with a valid AMS 2 SolrDocument' do

    let(:ams2_asset) { described_class.new(solr_document: solr_document) }
    let(:di_et_count) { asset.digital_instantiations.map{ |inst| DigitalInstantiation.find(inst["id"]).essence_tracks }.count }
    let(:pi_et_count) { asset.physical_instantiations.map{ |inst| PhysicalInstantiation.find(inst["id"]).essence_tracks }.count }

    describe '#solr_document' do
      it 'returns the correct SolrDocument' do
        expect(ams2_asset.solr_document[:id]).to eq(asset.id)
      end
    end

    describe '#digital_instantiations_count' do
      it 'returns the number of digital instantiations' do
        expect(ams2_asset.digital_instantiations_count).to eq(asset.digital_instantiations.count)
      end
    end

    describe '#physical_instantiations_count' do
      it 'returns the number of physical instantiations' do
        expect(ams2_asset.physical_instantiations_count).to eq(asset.physical_instantiations.count)
      end
    end

    describe '#essence_tracks_count' do
      it 'returns the number of essence tracks' do
        expect(ams2_asset.essence_tracks_count).to eq(di_et_count + pi_et_count)
      end
    end
  end
end
