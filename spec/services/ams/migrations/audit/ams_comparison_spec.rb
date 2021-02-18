require 'rails_helper'

RSpec.describe AMS::Migrations::Audit::AMSComparison do

  def stub_expected_counts(object:, digital_instantiations_count:, physical_instantiations_count:, essence_tracks_count:)
    allow_any_instance_of(object).to receive(:digital_instantiations_count).and_return digital_instantiations_count
    allow_any_instance_of(object).to receive(:physical_instantiations_count).and_return physical_instantiations_count
    allow_any_instance_of(object).to receive(:essence_tracks_count).and_return essence_tracks_count
  end

  let(:ams_comparison) { described_class.new("bupkus") }

  context 'when the AMS1Asset and AMS2Asset are present' do

    before do
      allow_any_instance_of(AMS::Migrations::Audit::AMS1Asset).to receive(:pbcore_present?).and_return true
      allow_any_instance_of(AMS::Migrations::Audit::AMS2Asset).to receive(:solr_document_present?).and_return true
    end

    describe '#assets_found?' do
      it 'returns true' do
        expect(ams_comparison.assets_found?).to eq(true)
      end
    end

    describe '#report' do
      context 'when the assets on AMS1 and AMS2 match' do
        let(:expected_report) { {
          "ams1" => { "digital_instantiations" => 1, "physical_instantiations" => 1, "essence_tracks" => 2 },
          "ams2" => { "digital_instantiations" => 1, "physical_instantiations" => 1, "essence_tracks" => 2 }
        } }

        before do
          stub_expected_counts(
            object: AMS::Migrations::Audit::AMS1Asset,
            digital_instantiations_count: 1,
            physical_instantiations_count: 1,
            essence_tracks_count: 2 )

          stub_expected_counts(
            object: AMS::Migrations::Audit::AMS2Asset,
            digital_instantiations_count: 1,
            physical_instantiations_count: 1,
            essence_tracks_count: 2 )
        end

        it 'returns the expected_report report' do
          expect(ams_comparison.report).to eq(expected_report)
        end
      end

      context 'when the assets on AMS1 and AMS2 do not match' do
        let(:expected_report) { {
          "ams1" => { "digital_instantiations" => 2, "physical_instantiations" => 2, "essence_tracks" => 3 },
          "ams2" => { "digital_instantiations" => 1, "physical_instantiations" => 1, "essence_tracks" => 2 }
        } }

        before do
          stub_expected_counts(
            object: AMS::Migrations::Audit::AMS1Asset,
            digital_instantiations_count: 2,
            physical_instantiations_count: 2,
            essence_tracks_count: 3 )

          stub_expected_counts(
            object: AMS::Migrations::Audit::AMS2Asset,
            digital_instantiations_count: 1,
            physical_instantiations_count: 1,
            essence_tracks_count: 2 )
        end

        it 'returns the expected report' do
          expect(ams_comparison.report).to eq(expected_report)
        end
      end
    end

    context 'when the AMS1Asset and AMS2Asset are not present' do

      before do
        allow_any_instance_of(AMS::Migrations::Audit::AMS1Asset).to receive(:pbcore_present?).and_return false
        allow_any_instance_of(AMS::Migrations::Audit::AMS2Asset).to receive(:solr_document_present?).and_return false
      end

      describe '#assets_found?' do
        it 'returns false' do
          expect(ams_comparison.assets_found?).to eq(false)
        end
      end

      describe '#report' do
        let(:expected_report) { {
            "ams1" => { "pbcore_present?" => false },
            "ams2" => { "solr_document_present?" => false }
          } }

        it 'returns the expected report' do
          expect(ams_comparison.report).to eq(expected_report)
        end
      end
    end
  end
end