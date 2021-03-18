require 'rails_helper'

RSpec.describe AMS::Migrations::Audit::AuditingService do
  let(:asset) { create(:asset) }
  let(:user) { create(:user) }

  context 'when an Asset is not on AMS1 or AMS2' do
    let(:auditing_service) { described_class.new(asset_ids: [ "bupkus" ], user: user ) }
    let(:error_report) { { "id" => "bupkus", "ams1" => { "pbcore_not_found?" => true }, "ams2" => { "solr_document_not_found?" => true } } }
    let(:expected_service_report) { { "matches" => [], "mismatches" => [], "errors" => [ error_report ] } }

    describe '#initialize' do
      it 'creates creates reader for asset_ids' do
        expect(auditing_service.asset_ids).to eq(Array("bupkus"))
      end
    end

    describe '#report' do
      before do
        allow_any_instance_of(AMS::Migrations::Audit::AMS1Asset).to receive(:pbcore_description_doc_found?).and_return false
      end

      it 'adds the expected errors' do
        expect(auditing_service.report).to eq(expected_service_report)
      end
    end
  end

  context 'when an AMS1Asset and AMS2Asset match' do
    let(:auditing_service) { described_class.new(asset_ids: [ asset.id ], user: user ) }
    let(:match_report) {
      { "ams1" => {
          "digital_instantiations" => 1,
          "physical_instantiations" => 1,
          "essence_tracks" => 1 },
        "ams2" => {
          "digital_instantiations" => 1,
          "physical_instantiations" => 1,
          "essence_tracks" => 1 }
      }
    }
    let(:expected_service_report) { { "matches" => [ match_report ], "mismatches" => [], "errors" => [] } }

    describe '#report' do
      before do
        allow_any_instance_of(AMS::Migrations::Audit::AMSComparison).to receive(:assets_match?).and_return true
        allow_any_instance_of(AMS::Migrations::Audit::AMS1Asset).to receive(:pbcore_description_doc_found?).and_return true
        allow_any_instance_of(AMS::Migrations::Audit::AMSComparison).to receive(:report).and_return match_report
      end

      it 'adds the expected matches' do
        expect(auditing_service.report).to eq(expected_service_report)
      end
    end
  end

  context 'when an AMS1Asset and AMS2Asset donna match' do
    let(:auditing_service) { described_class.new(asset_ids: [ asset.id ], user: user ) }
    let(:mismatch_report) {
      { "ams1" => {
          "digital_instantiations" => 1,
          "physical_instantiations" => 1,
          "essence_tracks" => 1 },
        "ams2" => {
          "digital_instantiations" => 1,
          "physical_instantiations" => 0,
          "essence_tracks" => 1 }
      }
    }
    let(:expected_service_report) { { "matches" => [], "mismatches" => [ mismatch_report ], "errors" => [] } }

    describe '#report' do
      before do
        allow_any_instance_of(AMS::Migrations::Audit::AMSComparison).to receive(:assets_match?).and_return false
        allow_any_instance_of(AMS::Migrations::Audit::AMS1Asset).to receive(:pbcore_description_doc_found?).and_return true
        allow_any_instance_of(AMS::Migrations::Audit::AMSComparison).to receive(:report).and_return mismatch_report
      end

      it 'adds the expected mismatches' do
        expect(auditing_service.report).to eq(expected_service_report)
      end
    end
  end
end