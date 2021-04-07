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
    before(:all) do
      @pbcore = create(:pbcore_description_document, :full_aapb, instantiations: build_list(:pbcore_instantiation, rand(1..3), :digital) + build_list(:pbcore_instantiation, rand(1..3), :physical))
      # Add 1-3 Essence Tracks for each instantiation
      @pbcore.instantiations.each do |instantiation|
        instantiation.essence_tracks = build_list(:pbcore_instantiation_essence_track, rand(1..3))
      end
    end

    before(:each) do
      allow_any_instance_of(described_class).to receive(:http_response).and_return @pbcore.to_xml
    end

    let(:id) { 'cpb-aacip_600-g73707wt6r' }

    describe '#pbcore' do
      it 'returns the AMS1 PBCore' do
        expect(ams1_asset.pbcore).to eq(@pbcore.to_xml)
      end
    end

    describe '#digital_instantiations_count' do
      it 'returns the number of digital instantiations' do
        expect(ams1_asset.digital_instantiations_count).to eq(@pbcore.instantiations.select{ |i| i.digital.present? }.count)
      end
    end

    describe '#physical_instantiations_count' do
      it 'returns the number of physical instantiations' do
        expect(ams1_asset.physical_instantiations_count).to eq(@pbcore.instantiations.select{ |i| i.physical.present? }.count)
      end
    end

    describe '#essence_tracks_count' do
      it 'returns the number of essence tracks' do
        expect(ams1_asset.essence_tracks_count).to eq(@pbcore.instantiations.map{ |i| i.essence_tracks.count }.sum)
      end
    end
  end
end
