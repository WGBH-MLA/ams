require 'rails_helper'
require 'pbcore'
require 'ams/migrations/audit/ams1_asset'

RSpec.describe AMS::Migrations::Audit::AMS1Asset do

  let(:ams1_asset) { described_class.new(id: id) }

  context 'with an invalid AMS 1 ID' do

    before(:each) do
      allow_any_instance_of(described_class).to receive(:http_response).and_return ams1_response
    end

    let(:id) { 'bupkus'}
    let(:ams1_response) { "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<error><string>Invalid GUID. No record found.</string></error>\n" }

    describe '#pbcore' do
      it 'returns nil' do
        expect(ams1_asset.pbcore).to eq(nil)
      end
    end

    describe '#digital_instantiations_count' do
      it 'returns nil' do
        expect(ams1_asset.digital_instantiations_count).to eq(nil)
      end
    end

    describe '#physical_instantiations_count' do
      it 'returns nil' do
        expect(ams1_asset.physical_instantiations_count).to eq(nil)
      end
    end

    describe '#essence_tracks_count' do
      it 'returns nil' do
        expect(ams1_asset.essence_tracks_count).to eq(nil)
      end
    end
  end

  context 'with a valid AMS 1 ID' do

    before(:each) do
      allow_any_instance_of(described_class).to receive(:http_response).and_return ams1_response
    end

    let(:id) { 'cpb-aacip_600-g73707wt6r' }
    let(:ams1_response) { File.open(File.join(fixture_path, 'batch_ingest', 'sample_pbcore2_xml', 'cpb-aacip_600-g73707wt6r.xml' )).read }

    describe '#pbcore' do
      it 'returns a string of PBCore' do
        expect(ams1_asset.pbcore).to eq(ams1_response)
      end
    end

    describe '#digital_instantiations_count' do
      it 'returns the number of digital instantiations' do
        expect(ams1_asset.digital_instantiations_count).to eq(0)
      end
    end

    describe '#physical_instantiations_count' do
      it 'returns the number of physical instantiations' do
        expect(ams1_asset.physical_instantiations_count).to eq(1)
      end
    end

    describe '#essence_tracks_count' do
      it 'returns the number of essence tracks' do
        expect(ams1_asset.essence_tracks_count).to eq(2)
      end
    end
  end
end
