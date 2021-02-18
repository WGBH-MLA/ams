require 'rails_helper'
require 'aapb/batch_ingest/pbcore_xml_item_ingester'

RSpec.describe AMS::Migrations::AuditingService do


  context 'when an Asset is not on AMS1 or AMS2' do
    let(:ids) { ["bupkus"] }
    let(:subject) { AMS::Migrations::AuditingService.new(ids) }

    before(:each) do
      allow_any_instance_of(AMS1Asset).to receive(:pbcore).and_return nil
      allow_any_instance_of(AMS2Asset).to receive(:solr_document).and_return nil
    end

    describe '#new' do
      it 'assigns the ids attr' do
        expect(subject.ids).to eq(invalid_id)
      end
    end

    describe '#run!' do
      let(:ams1_error) { { "bupkus" => { "ams1" => "Invalid AMS1 PBCore" } } }
      let(:ams2_error) { { "bupkus" => { "ams2" => "SolrDocument Not Present" } } }
      let(:output) { subject.run! }

      it 'adds the expected errors' do
        expect(output["errors"]).to include(ams1_error)
        expect(output["errors"]).to include(ams2_error)
      end
    end
  end

  # context 'when an Asset is on AMS1 and AMS2' do
  #   let(:ams_1_response) { @pbcore.to_xml }
  #   let(:match_response) { { "digital_instantiations" => 2, "physical_instantiations" => 1, "essence_tracks" => 3 } }
  #   let(:no_match_response) { { "digital_instantiations" => 1, "physical_instantiations" => 1, "essence_tracks" => 2 } }
  #   let(:output) { AMS::Migrations::AuditingService.new([ @asset.id ]).run! }

  #   before(:each) do
  #     @pbcore = build(:pbcore_description_document,
  #                     :full_aapb,
  #                     contributors: build_list(:pbcore_contributor, 1),
  #                     instantiations: [
  #                      build_list(:pbcore_instantiation, 2, :digital,
  #                        essence_tracks: build_list(:pbcore_instantiation_essence_track, 1)),
  #                      build(:pbcore_instantiation, :physical,
  #                        essence_tracks: build_list(:pbcore_instantiation_essence_track, 1))
  #                      ].flatten )

  #     @batch = create(:batch, submitter_email: create(:user, role_names: ['aapb-admin']).email)

  #     # Use the PBCore XML as the source data for a BatchItem.
  #     batch_item = create(:batch_item, batch: @batch, source_location: nil, source_data: @pbcore.to_xml)

  #     # Ingest the BatchItem and use the returned Asset instance for testing.
  #     @asset = AAPB::BatchIngest::PBCoreXMLItemIngester.new(batch_item).ingest
  #     # Reload for associations
  #     @asset.reload

  #     # Mock Response from AMS1
  #     allow_any_instance_of(described_class).to receive(:http_get).and_return ams_1_response
  #   end

  #   describe '#run' do
  #     it 'finds matches' do
  #       match_data = output["match"].find{ |asset| asset[@asset.id] }[@asset.id]

  #       expect(output["match"].length).to eq(1)
  #       expect(match_data["ams1"]).to eq(match_response)
  #       expect(match_data["ams2"]).to eq(match_response)
  #     end

  #     it 'finds mismatches' do
  #       DigitalInstantiation.find(@asset.digital_instantiations.sample["id"]).destroy
  #       no_match_data = output["no match"].find{ |asset| asset[@asset.id] }[@asset.id]

  #       expect(output["no match"].length).to eq(1)
  #       expect(no_match_data["ams1"]).to eq(match_response)
  #       expect(no_match_data["ams2"]).to eq(no_match_response)
  #     end
  #   end
  # end
end