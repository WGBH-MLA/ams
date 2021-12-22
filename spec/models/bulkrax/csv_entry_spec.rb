# frozen_string_literal: true
# rubocop: disable Metrics/BlockLength

require 'rails_helper'

module Bulkrax
  RSpec.describe CsvEntry, type: :model do
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
  end
end
# rubocop: enable Metrics/BlockLength
