require 'rails_helper'
require 'hyrax/batch_ingest/spec/shared_specs'
require 'aapb/batch_ingest/pbcore_xml_item_ingester'
require 'aapb/batch_ingest/pbcore_xml_instantiation_reset'
require 'tempfile'
require 'sidekiq/testing'

RSpec.describe AAPB::BatchIngest::PBCoreXMLInstantiationReset, reset_data: false do
  # Temporarily set ActiveJob queue adapter to :sidekiq for this test, since
  # it's an integration test that involves running ingest jobs.
  before(:all) do
    ActiveJob::Base.queue_adapter = :sidekiq
    Sidekiq::Testing.inline!
  end
  after(:all) { ActiveJob::Base.queue_adapter = :sidekiq }

  # An array of a single pbcoreIdentifier that is the AAPB ID, aka AssetResource ID.
  let(:pbcore_identifier) { build(:pbcore_identifier, :aapb) }

  # Create 2 PBCore XML docs with the same AAPB ID, ingesting the first one with
  # PBCoreXMLItemIngester (normal ingest), and then ingesting the 2nd with
  # PBCoreXMLInstantiationResetIngester (the class we are testing).
  # Our goal for happy path testing is to ensure that instantiations can be
  # reset to something new without affecting the AssetResource's other attributes
  # or related Contribution models.
  let(:pbcore_docs) do
    Array.new(2) do
      build(
        :pbcore_description_document,
        :full_aapb,
        identifiers: [ pbcore_identifier ],
        instantiations: [
          # Random number (1-3) of digital instantiations
          Array.new(rand(1..3)) do
            build(
              :pbcore_instantiation,
              :digital,
              identifiers: [ build(:pbcore_instantiation_identifier, source: 'test-local', value: SecureRandom.hex(5)) ]
            )
          end,

          # Random number (1-3) of physical instantiations
          Array.new(rand(1..3)) do
            build(
              :pbcore_instantiation,
              :physical,
              # Because we are ingesting we should not have an AAPB ID identifier,
              # which means we have to explicitly specify our identifiers because an
              # AAPB ID is included in factory-generated instantiations by default.
              identifiers: [ build(:pbcore_instantiation_identifier, source: 'test-local', value: SecureRandom.hex(5)) ]
            )
          end
          # Flatten the 2 lists of instantiations into a single list.
        ].flatten
      )
    end
  end

  # Build 2 BatchItems from the 2 tempfiles containing the factory-generated PBCore
  let(:batch_items) do
    pbcore_docs.map.with_index do |pbcore_doc, i|
      # Generate a Batch into which the BatchItem goes
      batch = build(:batch, submitter_email: create(:admin_user).email)

      # Write the PBCore to a file for use by the BatchItem ingester
      pbcore_file = Tempfile.create(["pbcore#{i}_", '.xml'])
      File.write(pbcore_file.path , pbcore_doc.to_xml)

      # Generate a BatchItem for the given pbcore_file
      build(:batch_item, batch: batch, source_location: pbcore_file.path, source_data: nil)
    end
  end

  let(:expected_inst_local_ids) do
    pbcore_docs
      .last                               # The last one used for PBCoreXMLInstantiationResetIngester (see above)
      .instantiations                     # map the docs to instantiations
      .map { |i| i.identifiers }.flatten  # map the instantiations to their identifiers
      .select { |i| i.source != 'ams' }   # select only the non-AMS identifiers (i.e. local identifiers)
      .map { |i| i.value }                # map to the unique values for comparison in tests.
  end

  let(:actual_inst_local_ids) do
    ar = AssetResource.find(pbcore_identifier.value)
    instantiations = ar.digital_instantiation_resources + ar.physical_instantiation_resources

    instantiations.map { |i| i.local_instantiation_identifier }.flatten
  end

  context "shared examples" do
    # Set expected test variables for for shared examples and run the shared examples.
    let(:ingester_class)  { described_class }
    let(:batch_item) { batch_items.first }
    let(:batch) { batch_items.first.batch }
    it_behaves_like "a Hyrax::BatchIngest::BatchItemIngester"
  end

  describe '#ingest' do
    subject { described_class.new(batch_items.last).ingest }

    context 'when the Asset is not in AMS' do
      it 'raises a Valkyrie::Persistence::ObjectNotFoundError error' do
        expect { subject }.to raise_error Valkyrie::Persistence::ObjectNotFoundError
      end
    end

    context 'when the Asset exists in AMS' do

      # Before each example in this spec:
      # 1. Ingest batch_item_1 with PBCoreXMLItemIngester
      # 2. Ingest batch_item_2 with PBCoreXMLInstantiationResetIngester
      before do
        AAPB::BatchIngest::PBCoreXMLItemIngester.new(batch_items.first).ingest
        # Fetch the AssetResource as it was first ingested. This represents an
        # "original" state of an AssetResource prior to running the
        # PBCoreXMLInstantiationReset ingester, which we can use for comparison
        @orig_asset_resource = AssetResource.find(pbcore_identifier.value).dup
        AAPB::BatchIngest::PBCoreXMLInstantiationReset.new(batch_items.last).ingest
      end

      let(:fetched_asset_resource) { AssetResource.find(pbcore_identifier.value) }

      let(:asset_property_methods) do
        [
          :bulkrax_identifier,
          :asset_types,
          :genre,
          :date,
          :broadcast_date,
          :created_date,
          :copyright_date,
          :episode_number,
          :spatial_coverage,
          :temporal_coverage,
          :audience_level,
          :audience_rating,
          :annotation,
          :rights_summary,
          :rights_link,
          :local_identifier,
          :pbs_nola_code,
          :eidr_id,
          :topics,
          :subject,
          :program_title,
          :episode_title,
          :segment_title,
          :raw_footage_title,
          :promo_title,
          :clip_title,
          :program_description,
          :episode_description,
          :segment_description,
          :raw_footage_description,
          :promo_description,
          :clip_description,
          :producing_organization,
          :admin_data_gid,
          :series_title,
          :series_description,
          :intended_children_count,
          :validation_status_for_aapb
        ]
      end

      it 'does not raise an exception' do
        expect { subject }.not_to raise_error
      end

      # HAPPY PATH SPEC! This is the main desired outcome.
      it 'sets the instantiations to the new values' do
        expect(actual_inst_local_ids).to eq expected_inst_local_ids
      end

      it 'does not udpate Admin Data' do
        expect(fetched_asset_resource.admin_data).to eq @orig_asset_resource.admin_data
      end

      it 'does not update Annotations' do
        expect(fetched_asset_resource.annotations).to eq @orig_asset_resource.annotations
      end

      it 'does not update the Asset attributes' do
        asset_property_methods.each do |asset_property_method|
          expect(fetched_asset_resource.send(asset_property_method)).to eq @orig_asset_resource.send(asset_property_method)
        end
      end

      it 'does not update the Contributions' do
        expect(fetched_asset_resource.contributions).to eq @orig_asset_resource.contributions
      end
    end
  end
end