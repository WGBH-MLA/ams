require 'rails_helper'
require 'hyrax/batch_ingest/spec/shared_specs'
require 'aapb/batch_ingest/pbcore_xml_item_ingester'

RSpec.describe AAPB::BatchIngest::PBCoreXMLItemIngester, reset_data: false do
  let(:ingester_class) { described_class }
  let(:submitter) { create(:user) }
  let(:batch) { build(:batch, submitter_email: submitter.email) }
  let(:sample_source_location) { File.join(fixture_path, 'batch_ingest', 'sample_pbcore2_xml', 'cpb-aacip_600-g73707wt6r.xml' ) }
  let(:batch_item) { build(:batch_item, batch: batch, source_location: sample_source_location)}

  it_behaves_like "a Hyrax::BatchIngest::BatchItemIngester"

  describe '#ingest' do
    context 'given a PBCore Description Document with Contributors, Digital Instantiations, and a Physical Instantiation' do
      # Before all, build PBCore XML containing Contributors, Digital
      # Instantiations, and a Physical Instantiation and ingest it. Use the
      # PBCore XML as the source data for a BatchItem instance, and then use the
      # PBCoreXMLItemIngester to ingest the BatchItem. The return value is an
      # Asset model instance on which we can write our expectations.
      before :all do
        # Build the PBCore XML
        pbcore_xml = FactoryBot.build(
          :pbcore_description_document,
          identifiers: [
            build(:pbcore_identifier, :aapb)
          ],
          contributors: build_list(:pbcore_contributor, 5),
          instantiations: [
            build_list(:pbcore_instantiation, 5, :digital,
                       essence_tracks: build_list(:pbcore_instantiation_essence_track, 2)),
            build(:pbcore_instantiation, :physical,
                  essence_tracks: build_list(:pbcore_instantiation_essence_track, 2))
          ].flatten
        ).to_xml

        @batch = create(:batch, submitter_email: create(:user).email)

        # Use the PBCore XML as the source data for a BatchItem.
        batch_item = create(
          :batch_item,
          batch: @batch,
          source_location: nil,
          source_data: pbcore_xml
        )

        # Ingest the BatchItem and use the returned Asset instance for testing.
        @asset = described_class.new(batch_item).ingest
        @asset.reload
        @contributions = @asset.members.select { |member| member.is_a? Contribution }
        @digital_instantiations = @asset.members.select { |member| member.is_a? DigitalInstantiation }
        @physical_instantiations = @asset.members.select { |member| member.is_a? PhysicalInstantiation }
        @essence_tracks = @digital_instantiations.map(&:members).flatten.select { |member| member.is_a? EssenceTrack }
        @essence_tracks += @physical_instantiations.map(&:members).flatten.select { |member| member.is_a? EssenceTrack }
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

      it 'propagates additional batch items as part of the batch' do
        # This number reflects the Asset, the Digital Instantiations, the
        # Physical Instantiations, and the Essence Tracks coming from Physical
        # Instnatiations.
        expect(@batch.batch_items.count).to eq 9
      end
    end

    context 'given a PBCore Instantiation Document with Essence Tracks' do
      # Before all, build a PBCore Instantiation Document with Essence Tracks
      # Instantiations, and a Physical Instantiation and ingest it. Use the
      # PBCore XML as the source data for a BatchItem instance, and then use the
      # PBCoreXMLItemIngester to ingest the BatchItem. The return value is an
      # DigitalInstantiation model instance on which we can write our expectations.
      before :all do
        # Build the PBCore XML
        pbcore_xml = FactoryBot.build(:pbcore_instantiation_document, :media_info).to_xml

        asset = create(:asset, id: "123456")

        # Use the PBCore XML as the source data for a BatchItem.
        batch_item = build(
          :batch_item,
          batch: build(:batch, submitter_email: create(:user).email),
          id_within_batch: "sample_digital_instantiation.xml",
          source_location: File.join(fixture_path, "batch_ingest", "sample_pbcore_digital_instantiation", "digital_instantiation_manifest.xlsx"),
          source_data: pbcore_xml
        )

        # Ingest the BatchItem and use the returned DigitalInstantiation instance for testing.
        @instantiation = described_class.new(batch_item).ingest
        @essence_tracks = @instantiation.essence_tracks
      end

      it 'creates a DigitalInstantiation' do
        expect(@instantiation).to be_instance_of(DigitalInstantiation)
      end

      it 'creates an associated EssenceTrack' do
        expect(@essence_tracks.count).to eq(1)
      end

    end
  end
end
