# frozen_string_literal: true
# rubocop: disable Metrics/BlockLength

require 'rails_helper'

module Bulkrax
  # TODO: Handle resolving these specs in https://github.com/scientist-softserv/ams/issues/105
  RSpec.describe CsvEntry, type: :model, skip: 'Skipping CsvEntry tests' do
    let(:path) { './spec/fixtures/bulkrax/csv/good.csv' }
    let(:data) { described_class.read_data(path) }
    let(:parsed_data) {
      {
        "Asset"=>nil,
        "Asset.local_identifier"=>"2017-01-07-stewartm-02",
        "Asset.producing_organization"=>"BirdNote",
        "Asset.level_of_user_access"=>"Online Reading Room",
        "Asset.asset_types"=>"Episode",
        "Asset.subject"=>"Birds",
        "Asset.rights_summary"=>
        "Sounds for BirdNote stories were provided by the Macaulay Library at the Cornell Lab of Ornithology, Xeno-Canto, Martyn Stewart, Chris Peterson, John Kessler, and others. Where music was used, fair use was taken into consideration. Individual credits are found at the bottom of each transcript.",
        "Asset.topics"=>"Science",
        "Asset.special_collections"=>"birdnote",
        "Asset.transcript_status"=>"Correct",
        "Asset.created_date"=>"2017-01-07",
        "Asset.series_title"=>"BirdNote",
        "Asset.episode_title"=>"Martyn Stewart Part II",
        "Asset.episode_description"=>
        "Martyn Stewart's calling is recording the sounds of birds and nature. He describes some of the rewards of working in the Arctic National Wildlife Refuge: \"It is a great place to go record birds and animals. You know generally that once you point your microphone at a nesting bird or a bird that's hopping through the tundra, it's going to be pristine. You haven't got a leaf-blower or an ATV or a plane flying over the top of you ... It's just a beautiful place.\"",
        "Contribution"=>nil,
        "Contribution.contributor"=>nil,
        "Contribution.contributor_role"=>nil,
        "PhysicalInstantiation"=>nil,
        "PhysicalInstantiation.local_instantiation_identifier"=>"stewartm-02",
        "PhysicalInstantiation.format"=>"Hard Drive",
        "PhysicalInstantiation.holding_organization"=>"BirdNote",
        "PhysicalInstantiation.generations"=>"Master",
        "PhysicalInstantiation.media_type"=>"Sound",
        "PhysicalInstantiation.location"=>"BirdNote Archive, Kessler Productions, Shoreline WA",
        "PhysicalInstantiation.duration"=>"00:01:45"
      }
    }
    let(:invalid_raw_metadata) {
      {
        "model"=>"Asset",
        "bad_header"=>"Saturday_Night_Live_Reference",
        "bad_header_two"=>"Saturday_Night_Live_Reference",
        "asset_types"=>"Clip",
      }
    }
    let(:valid_raw_metadata) {
      {
        "model"=>"Asset",
        "local_identifier"=>"Saturday_Night_Live_Reference",
        "asset_types"=>"Clip",
        "broadcast_date"=>"1990-04-21",
        "series_title"=>"Saturday Night Live",
        "episode_title"=>"Saturday Night Live - Bill Moyers Reference",
        "episode_description"=>"This segment of Saturday Night Live",
        "genre"=>"Humor",
        "children"=>["2-PhysicalInstantiation-0-1"]
      }
    }

    describe 'class methods' do
      describe '#read_data' do
        it 'reads the data from an csv file' do
          expect(described_class.read_data(path)).to be_a(CSV::Table)
        end
      end

      describe '#data_for_entry' do
        it 'retrieves the data and constructs a hash' do
          expect(described_class.data_for_entry(data)).to eq(parsed_data)
        end
      end
    end

    describe 'builds entry' do
      subject { described_class.new(importerexporter: importer) }
      let(:importer) { FactoryBot.create(:bulkrax_importer_csv) }

      context 'without required metadata' do
        before do
          allow(subject).to receive(:record).and_return(source_identifier: '1', some_field: 'some data')
        end

        it 'fails and stores an error' do
          expect { subject.build_metadata }.to raise_error(StandardError)
        end
      end

      context 'with required metadata' do
        before do
          allow_any_instance_of(ObjectFactory).to receive(:run!)
          allow(subject).to receive(:raw_metadata).and_return(valid_raw_metadata)
        end

        it 'succeeds' do
          subject.build
          expect(subject.status).to eq('Complete')
          expect(subject.parsed_metadata['admin_set_id']).to eq 'MyString'
        end

        it 'has a source id field' do
          expect(subject.source_identifier).to eq('source_identifier')
        end

        it 'has a work id field' do
          expect(subject.work_identifier).to eq('source')
        end

        it 'has custom source and work id fields' do
          subject.importerexporter.field_mapping['bulkrax_identifier'] = { 'from' => ['bulkrax_identifier'], 'source_identifier' => true }
          expect(subject.source_identifier).to eq('bulkrax_identifier')
          expect(subject.work_identifier).to eq('bulkrax_identifier')
        end
      end
    end

    describe 'exporting by Asset worktype' do
      subject { described_class.new(importerexporter: exporter, identifier: asset.id, parsed_metadata: {}) }
      let(:exporter) { FactoryBot.create(:bulkrax_exporter_worktype, parser_klass: 'CsvParser', export_source: 'Asset') }
      let(:asset) { FactoryBot.create(:asset, :with_two_physical_instantiations) }
      let(:headers) { exporter.parser.export_headers }

      before do
        subject.build_export_metadata
      end

      describe 'with class method' do
        context '#build_export_metadata' do
          it 'returns parent and children data as a single hash' do
            expect(subject.parsed_metadata['Asset_1']).to eq('')
            expect(subject.parsed_metadata['Asset.spatial_coverage_1']).to eq('TEST spatial_coverage')
            # each group of child models is listed in reverse order
            # e.g. the last imported physical instantiation, will be listed first on the csv
            expect(subject.parsed_metadata['PhysicalInstantiation_1']).to eq('')
            expect(subject.parsed_metadata['PhysicalInstantiation.annotation_1']).to eq('Test annotation')
            expect(subject.parsed_metadata['PhysicalInstantiation.holding_organization_1']).to eq('American Archive of Public Broadcasting')
            expect(subject.parsed_metadata['PhysicalInstantiation_2']).to eq('')
            expect(subject.parsed_metadata['PhysicalInstantiation.annotation_2']).to eq('Minimal annotation')
          end
        end
      end

      describe 'creates the correct headers' do
        before do
          exporter.export
        end

        context 'including' do
          it 'valid Asset headers' do
            expect(headers).to include('Asset_1')
            expect(headers).to include('Asset.annotation_1')
            expect(headers).to include('Asset.audience_level_1')
            expect(headers).to include('Asset.broadcast_date_1')
            expect(headers).to include('Asset.clip_description_1')
            expect(headers).to include('Asset.date_1')
            expect(headers).to include('Asset.episode_description_1')
            expect(headers).to include('Asset.genre_1')
            expect(headers).to include('Asset.local_identifier_1')
            expect(headers).to include('Asset.pbs_nola_code_1')
            expect(headers).to include('Asset.rights_summary_1')
            expect(headers).to include('Asset.subject_1')
            expect(headers).to include('Asset.topics_1')
          end

          it 'valid PhysicalInstantation headers' do
            expect(headers).to include('PhysicalInstantiation_1')
            expect(headers).to include('PhysicalInstantiation.annotation_1')
            expect(headers).to include('PhysicalInstantiation.date_1')
            expect(headers).to include('PhysicalInstantiation.holding_organization_1')
            expect(headers).to include('PhysicalInstantiation.local_instantiation_identifier_1')
            expect(headers).to include('PhysicalInstantiation.location_1')
            expect(headers).to include('PhysicalInstantiation.media_type_1')
            expect(headers).to include('PhysicalInstantiation_2')
            expect(headers).to include('PhysicalInstantiation.annotation_2')
            expect(headers).to include('PhysicalInstantiation.location_2')
            expect(headers).to include('PhysicalInstantiation.media_type_2')
          end
        end

        context 'not including' do
          it 'invalid model headers' do
            expect(headers).not_to include('Asset.holding_organization_1')
            expect(headers).not_to include('PhysicalInstantiation.admin_data_gid_1')
          end
        end
      end

      describe 'writes the csv file' do
        before do
          exporter.write
        end

        xit 'with the asset and its children in a single row' do
          # TODO(alishaevn): write this spec
        end
      end
    end
  end
end
# rubocop: enable Metrics/BlockLength
