require 'rails_helper'

RSpec.describe AMS::Migrations::Audit::AMSComparison do
  let(:ams1_asset) { instance_double(AMS::Migrations::Audit::AMS1Asset, id: id, pbcore_description_doc_found?: true) }
  let(:ams2_asset) { instance_double(AMS::Migrations::Audit::AMS2Asset, solr_document: SolrDocument.new('id' => id )) }
  let(:id) { 'cpb-aacip-bupkus1' }
  let(:ams_comparison) { described_class.new(ams1_asset: ams1_asset, ams2_asset: ams2_asset) }

  before(:each) do
    allow(ams1_asset).to receive(:class).and_return AMS::Migrations::Audit::AMS1Asset
    allow(ams1_asset).to receive(:digital_instantiations_count).and_return ams1_di_count
    allow(ams1_asset).to receive(:physical_instantiations_count).and_return ams1_pi_count
    allow(ams1_asset).to receive(:essence_tracks_count).and_return ams1_et_count
    allow(ams2_asset).to receive(:class).and_return AMS::Migrations::Audit::AMS2Asset
    allow(ams2_asset).to receive(:digital_instantiations_count).and_return ams2_di_count
    allow(ams2_asset).to receive(:physical_instantiations_count).and_return ams2_pi_count
    allow(ams2_asset).to receive(:essence_tracks_count).and_return ams2_et_count
  end

  context 'when the AMS1Asset and AMS2Asset are present' do
    let(:ams1_di_count) { rand(0..10) }
    let(:ams1_pi_count) { rand(0..10) }
    let(:ams1_et_count) { rand(0..10) }
    let(:ams2_di_count) { rand(0..10) }
    let(:ams2_pi_count) { rand(0..10) }
    let(:ams2_et_count) { rand(0..10) }

    let(:report) { ams_comparison.report }

    describe '#report' do
      it 'returns the expected report format' do
        expect(report["id"]).to eq(id)
        expect(report["ams1"]["digital_instantiations"]).to eq(ams1_di_count)
        expect(report["ams1"]["physical_instantiations"]).to eq(ams1_pi_count)
        expect(report["ams1"]["essence_tracks"]).to eq(ams1_et_count)
        expect(report["ams2"]["digital_instantiations"]).to eq(ams2_di_count)
        expect(report["ams2"]["physical_instantiations"]).to eq(ams2_pi_count)
        expect(report["ams2"]["essence_tracks"]).to eq(ams2_et_count)
      end
    end

    describe '#assets_match?' do
      context 'when the AMS1Asset and AMS2Asset counts match' do
        let(:ams1_di_count) { 1 }
        let(:ams1_pi_count) { 1 }
        let(:ams1_et_count) { 1 }
        let(:ams2_di_count) { 1 }
        let(:ams2_pi_count) { 1 }
        let(:ams2_et_count) { 1 }

        it 'returns true' do
          expect(ams_comparison.assets_match?).to eq(true)
        end
      end

      context 'when the AMS1Asset and AMS2Asset counts do not match' do
        let(:ams1_di_count) { 1 }
        let(:ams1_pi_count) { 1 }
        let(:ams1_et_count) { 1 }
        let(:ams2_di_count) { 2 }
        let(:ams2_pi_count) { 2 }
        let(:ams2_et_count) { 2 }

        it 'returns false' do
          expect(ams_comparison.assets_match?).to eq(false)
        end
      end
    end
  end
end