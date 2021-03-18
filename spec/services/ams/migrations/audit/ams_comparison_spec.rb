require 'rails_helper'

RSpec.describe AMS::Migrations::Audit::AMSComparison do

  def stub_expected_counts(object:, digital_instantiations_count:, physical_instantiations_count:, essence_tracks_count:)
    allow(object).to receive(:digital_instantiations_count).and_return digital_instantiations_count
    allow(object).to receive(:physical_instantiations_count).and_return physical_instantiations_count
    allow(object).to receive(:essence_tracks_count).and_return essence_tracks_count
  end

  let(:ams1_asset) { double() }
  let(:ams2_asset) { double() }
  let(:id) { 'cpb-aacip-bupkus1' }
  let(:ams_comparison) { described_class.new(ams1_asset: ams1_asset, ams2_asset: ams2_asset) }

  before do
    allow(ams1_asset).to receive(:class).and_return AMS::Migrations::Audit::AMS1Asset
    allow(ams2_asset).to receive(:class).and_return AMS::Migrations::Audit::AMS2Asset
    allow(ams1_asset).to receive(:id).and_return id
    allow(ams2_asset).to receive(:id).and_return id
    allow(ams1_asset).to receive(:pbcore_description_doc_found?).and_return true
    allow(ams2_asset).to receive(:solr_document).and_return SolrDocument.new('id' => id )
  end

  context 'when the AMS1Asset and AMS2Asset are present' do
    describe '#report' do
      let(:expected_report) { {
        "id" => id,
        "ams1" => { "digital_instantiations" => 1, "physical_instantiations" => 1, "essence_tracks" => 2 },
        "ams2" => { "digital_instantiations" => 1, "physical_instantiations" => 1, "essence_tracks" => 2 }
      } }

      before do
        stub_expected_counts(
          object: ams1_asset,
          digital_instantiations_count: 1,
          physical_instantiations_count: 1,
          essence_tracks_count: 2 )

        stub_expected_counts(
          object: ams2_asset,
          digital_instantiations_count: 1,
          physical_instantiations_count: 1,
          essence_tracks_count: 2 )
      end

      it 'returns the expected report format' do
        expect(ams_comparison.report).to eq(expected_report)
      end
    end

    describe '#assets_match?' do

      context 'when the AMS1Asset and AMS2Asset counts match' do
        before do
          stub_expected_counts(
            object: ams1_asset,
            digital_instantiations_count: 1,
            physical_instantiations_count: 1,
            essence_tracks_count: 2 )

          stub_expected_counts(
            object: ams2_asset,
            digital_instantiations_count: 1,
            physical_instantiations_count: 1,
            essence_tracks_count: 2 )
        end

        it 'returns true' do
          expect(ams_comparison.assets_match?).to eq(true)
        end
      end

      context 'when the AMS1Asset and AMS2Asset counts do not match' do
        before do
          stub_expected_counts(
            object: ams1_asset,
            digital_instantiations_count: [1..5].sample,
            physical_instantiations_count: [1..5].sample,
            essence_tracks_count: [1..5].sample )

          stub_expected_counts(
            object: ams2_asset,
            digital_instantiations_count: [5..10].sample,
            physical_instantiations_count: [1..5].sample,
            essence_tracks_count: [1..10].sample )
        end

        it 'returns false' do
          expect(ams_comparison.assets_match?).to eq(false)
        end
      end
    end
  end
end