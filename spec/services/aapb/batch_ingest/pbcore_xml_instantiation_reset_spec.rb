require 'rails_helper'
require 'hyrax/batch_ingest/spec/shared_specs'
require 'aapb/batch_ingest/pbcore_xml_item_ingester'
require 'aapb/batch_ingest/pbcore_xml_instantiation_reset'

RSpec.describe AAPB::BatchIngest::PBCoreXMLInstantiationReset, reset_data: false do
  let(:ingester_class) { described_class }
  let(:submitter) { create(:user) }
  let(:batch) { build(:batch, submitter_email: submitter.email) }
  let(:sample_source_location) { File.join(fixture_path, 'batch_ingest', 'sample_pbcore2_xml', 'cpb-aacip_600-g73707wt6r.xml' ) }
  let(:batch_item) { build(:batch_item, batch: batch, source_location: sample_source_location)}

  it_behaves_like "a Hyrax::BatchIngest::BatchItemIngester"

  describe '#ingest' do
    context 'given a PBCore Description Document with Contributors, Digital Instantiations, and a Physical Instantiation' do
      before :all do
        @pbcore = build(:pbcore_description_document,
                        :full_aapb,
                        contributors: build_list(:pbcore_contributor, 5),
                        instantiations: [
                         build_list(:pbcore_instantiation, 5, :digital,
                           essence_tracks: build_list(:pbcore_instantiation_essence_track, 2)),
                         build(:pbcore_instantiation, :physical,
                           essence_tracks: build_list(:pbcore_instantiation_essence_track, 2))
                         ].flatten )

        @batch = create(:batch, submitter_email: create(:user, role_names: ['aapb-admin']).email)

        # Use the PBCore XML as the source data for a BatchItem.
        batch_item = create(
          :batch_item,
          batch: @batch,
          source_location: nil,
          source_data: @pbcore.to_xml
        )

        # Ingest the BatchItem and use the returned Asset instance for testing.
        @asset = AAPB::BatchIngest::PBCoreXMLItemIngester.new(batch_item).ingest
        @asset = AssetResource.find(@asset.id)
        # Here we grab a few things off the @asset that we want to test in order
        # to make tests a bit cleaner.
        @contributions = @asset.contribution_resources
        @digital_instantiations = @asset.digital_instantiation_resources
        @physical_instantiations = @asset.physical_instantiation_resources
        @essence_tracks = @digital_instantiations.map(&:essence_track_resources).flatten
        @essence_tracks += @physical_instantiations.map(&:essence_track_resources).flatten
        @admin_data = AdminData.find_by_gid @asset.admin_data_gid
      end

      it 'ingests the Asset and the Contributions' do
        expect(@contributions.count).to eq 5
      end

      it 'ingests the Asset and the Digital Instantiations' do
        expect(@digital_instantiations.count).to eq 5
      end

      it 'ingests the Asset and the Physical Instantiations' do
        expect(@physical_instantiations.count).to eq 1
      end

      it 'ingests the Essence Tracks of Digital and Physical Instantiations' do
        expect(@essence_tracks.count).to eq 12
      end

      xit 'does not udpate Admin Data' do
      end

      xit 'does not update Annotations' do
      end

      context 'when trying to reset instantiations for an Asset that is not yet in AMS' do
        it 'raises an exception' do
          duplicate_batch_item = create(
            :batch_item,
            batch: @batch,
            source_location: nil,
            source_data: @pbcore.to_xml
          )
          expect { described_class.new(duplicate_batch_item).ingest }.to raise_error
        end
      end
    end
  end
end
