require 'rails_helper'
require 'hyrax/batch_ingest/spec/shared_specs'
require 'aapb/batch_ingest/pbcore_xml_item_ingester'
require 'aapb/batch_ingest/pbcore_xml_instantiation_reset'
require 'tempfile'

RSpec.describe AAPB::BatchIngest::PBCoreXMLInstantiationReset, reset_data: false do

  # An array of a single pbcoreIdentifier that is the AAPB ID, aka AssetResource ID.
  let(:pbcore_identifier) { build(:pbcore_identifier, :aapb) }

  # Create 2 PBCore XML docs with the same AAPB ID, ingesting the first one with
  # PBCoreXMLItemIngester (normal ingest), and then ingesting the 2nd with the
  # class under test: PBCoreXMLInstantiationResetIngester.
  let(:pbcore_docs) do
    build_list(
      :pbcore_description_document,
      2,
      :full_aapb,
      identifiers: [ pbcore_identifier ],
      instantiations: [
        build_list(
          :pbcore_instantiation,
          # Random number of DIGITAL instantiations
          rand(1..3),
          :digital,
          # Because we are ingesting we should not have an AAPB ID identifier,
          # which means we have to explicitly specify our identifiers because an
          # AAPB ID in in factory-generated instantiations added by default.
          identifiers: [ build(:pbcore_instantiation_identifier) ]
        ),
        build_list(
          :pbcore_instantiation,
          # Random number of PHYSICAL instantiations
          rand(1..3),
          :physical,
          # Because we are ingesting we should not have an AAPB ID identifier,
          # which means we have to explicitly specify our identifiers because an
          # AAPB ID in in factory-generated instantiations added by default.
          identifiers: [ build(:pbcore_instantiation_identifier) ]
        )        
        # Flatten the 2 lists of instantiations into a single list.
      ].flatten
    )
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

  let(:orig_instantiations) do
    pbcore_docs
      .first
      .instantiations
      .select { |i| i.digital }
  end

  # expected_instantiations - PBCore XML of the new digital
  # instantiations being input for ingestion (i.e. the expected result when
  # comparing for correctness)
  let(:expected_instantiations) do
    pbcore_docs
      .last
      .instantiations
      .select { |i| i.digital }
  end

  # fetched_asset_pbcore_instantitaions - PBCore XML of the new instantiations
  # after ingestion (i.e. the actual result when comparing for correctness)
  # NOTE: depends on `before` block below running successfully, which it should
  # do automatically prior to each example within the same context, including
  # nested contexts.
  let(:actual_instantiations) do
    x = PBCore::DescriptionDocument.parse(
      SolrDocument.find(pbcore_identifier.value).export_as_pbcore
    ).instantiations
      .select { |i| i.digital }
  end

  context "shared examples" do
    # Set expected test variables for for shared examples and run the shared examples.
    let(:ingester_class)  { described_class }
    let(:batch_item) { batch_items.first }
    let(:batch) { batch_items.first.batch }
    it_behaves_like "a Hyrax::BatchIngest::BatchItemIngester"
  end


  # Before each example in this spec:
  # 1. ingest batch_item_1 with PBCoreXMLItemIngester
  # 2. ingest batch_item_2 with PBCoreXMLInstantiationResetIngester
  before do

    require 'pry'; binding.pry

    AAPB::BatchIngest::PBCoreXMLItemIngester.new(batch_items.first).ingest
    @orig_asset_resource = AssetResource.find(pbcore_identifier.value).dup
    AAPB::BatchIngest::PBCoreXMLInstantiationReset.new(batch_items.last).ingest
  end

  describe '#ingest' do

    subject { described_class.new(batch_items.last).ingest }

    context 'when the Asset is not in AMS' do
      it 'raises an exception with a useful message' do
        expect { subject }.to raise_error('REPLACE WITH EXPECTED MESSAGE')
      end
    end

    context 'when the Asset exists in AMS' do
      context 'and when there is an error in the instantiations being reset' do
        it 'raises an exception with a useful message' do
          expect { subject }.to raise_error('REPLACE WITH VALIDATION MESSAGE')
        end
      end

      context 'and when there is no error in the instantiations being reset' do
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

        it 'sets the instantiations to the new values', :focus do
          require 'pry'; binding.pry
          expect(actual_instantiations).to eq expected_instantiations
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
end