require 'rails_helper'

RSpec.describe AMS::Migrations::Audit::AuditingService do
  let(:asset) { create(:asset) }
  let(:user) { create(:user) }
  let(:comparison_report) {
    { "id" => asset.id,
      "ams1" => {
        "digital_instantiations" => ams1_di_count,
        "physical_instantiations" => ams1_pi_count,
        "essence_tracks" => ams1_et_count },
      "ams2" => {
        "digital_instantiations" => ams2_di_count,
        "physical_instantiations" => ams2_pi_count,
        "essence_tracks" => ams2_et_count }
    }
  }

  context 'when an Asset is not on AMS1 or AMS2' do
    let(:id) { "bupkus" }
    let(:auditing_service) { described_class.new(asset_ids: [ id ], user: user ) }
    let(:report) { auditing_service.report }
    let(:error_report) { report["errors"].select{ |error| error["id"] == id }.first }

    describe '#initialize' do
      it 'creates creates reader for asset_ids' do
        expect(auditing_service.asset_ids).to eq(Array("#{id}"))
      end
    end

    describe '#report' do
      before do
        allow_any_instance_of(AMS::Migrations::Audit::AMS1Asset).to receive(:pbcore_description_doc_found?).and_return false
      end

      it 'adds the expected errors' do
        expect(error_report["ams1"]["pbcore_not_found?"]).to eq(true)
        expect(error_report["ams2"]["solr_document_not_found?"]).to eq(true)
      end
    end
  end

  context 'when an AMS1Asset and AMS2Asset match' do
    let(:report) { described_class.new(asset_ids: [ asset.id ], user: user ).report }
    let(:ams1_di_count) { rand(0..10) }
    let(:ams1_pi_count) { rand(0..10) }
    let(:ams1_et_count) { rand(0..10) }
    # Set AMS2 values to match
    let(:ams2_di_count) { ams1_di_count }
    let(:ams2_pi_count) { ams1_pi_count }
    let(:ams2_et_count) { ams1_et_count }

    describe '#report' do
      before do
        allow_any_instance_of(AMS::Migrations::Audit::AMSComparison).to receive(:assets_match?).and_return true
        allow_any_instance_of(AMS::Migrations::Audit::AMS1Asset).to receive(:pbcore_description_doc_found?).and_return true
        allow_any_instance_of(AMS::Migrations::Audit::AMSComparison).to receive(:report).and_return comparison_report
      end

      it 'adds the comparison report to the report\'s matches data' do
        skip "ams.americanarchive.org is down"
        expect(report["matches"].count).to eq(1)
      end
    end
  end

  context 'when an AMS1Asset and AMS2Asset donna match' do
    let(:report) { described_class.new(asset_ids: [ asset.id ], user: user ).report }
    let(:ams1_di_count) { rand(0..5) }
    let(:ams1_pi_count) { rand(0..5) }
    let(:ams1_et_count) { rand(0..5) }
    let(:ams2_di_count) { rand(6..10) }
    let(:ams2_pi_count) { rand(6..10) }
    let(:ams2_et_count) { rand(6..10) }

    describe '#report' do
      before do
        allow_any_instance_of(AMS::Migrations::Audit::AMSComparison).to receive(:assets_match?).and_return false
        allow_any_instance_of(AMS::Migrations::Audit::AMS1Asset).to receive(:pbcore_description_doc_found?).and_return true
        allow_any_instance_of(AMS::Migrations::Audit::AMSComparison).to receive(:report).and_return comparison_report
      end

      it 'adds the comparison report to the report\'s mismatches data' do
        skip "ams.americanarchive.org is down"
        expect(report["mismatches"].count).to eq(1)
      end
    end
  end
end
