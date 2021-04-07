require 'rails_helper'
require 'pbcore'
require 'ams/migrations/audit/ams2_asset'

RSpec.describe AMS::Migrations::Audit::AMS2Asset do
  let(:digital_instantiations) {
    create_list(:digital_instantiation, rand(1..3)) do |di, i|
      di.ordered_members = create_list(:essence_track, rand(0..3))
    end
  }

  let(:physical_instantiations) {
    create_list(:physical_instantiation, rand(1..3)) do |pi, i|
      pi.ordered_members = create_list(:essence_track, rand(0..3))
    end
  }

  let(:ordered_members) { [ digital_instantiations + physical_instantiations ].flatten }
  let(:asset) { create(:asset, ordered_members: ordered_members) }
  let(:solr_document) { SolrDocument.find(asset.id) }

  context 'with a valid AMS 2 SolrDocument' do
    let(:ams2_asset) { described_class.new(solr_document: solr_document) }
    let(:essence_track_count) { SolrDocument.get_members(asset.id).select{ |member_id| SolrDocument.find(member_id)["has_model_ssim"].include?("EssenceTrack") }.count }

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
        expect(ams2_asset.essence_tracks_count).to eq(essence_track_count)
      end
    end
  end
end
