require 'rails_helper'
require 'concerns/ams2_pbcore_validator'
require 'concerns/ams2_pbcore'
require 'ams/cleaner/vocab_map'


RSpec.describe AMS2PBCoreValidator do

  subject { AMS2PBcore.new( pbcore: build(:pbcore_description_document,
    :full_aapb, asset_types: [ build(:pbcore_asset_type, value: asset_type) ], asset_dates: asset_dates, titles: asset_titles,
    instantiations: build_list(:pbcore_instantiation, rand(1..3), :digital) + build_list(:pbcore_instantiation, rand(1..3), :physical)))
  }

  let(:config) { {
    "asset_type" => { "values" => { "Album" => "Album", "Clip" => "Clip", "Compilation" => "Compilation", "Raw Footage" => "Raw Footage" } },
    "asset_date" => { "types" => { "broadcast" => "Broadcast", "air" => "Broadcast", "issue" => "Broadcast", "created" => "Created" } }
  } }


  before(:each) do
    allow(YAML).to receive(:load_file).and_return(config)
    subject.validate
  end

  context '.validate' do
    describe 'PBCore with invalid data' do
      let(:asset_dates) { [ build(:pbcore_asset_date, type: date_type, value: date_value) ] }
      let(:asset_titles) { [ build(:pbcore_title, type: asset_title_type, value: asset_title_value), build(:pbcore_title) ] }
      let(:asset_type) { SecureRandom.hex.slice(0..7) }
      let(:date_type) { SecureRandom.hex.slice(0..7) }
      let(:date_value) { SecureRandom.hex.slice(0..7) }
      let(:asset_title_type) { SecureRandom.hex.slice(0..7) }
      let(:asset_title_value) { nil }

      it 'is processed as invalid' do
        expect(subject).not_to be_valid
      end

      it 'Invalid AssetType adds a controlled vocabulary error' do
        expect(subject.errors.messages[:base]).to include("Invalid PBCore::AssetType value: #{asset_type}")
      end

      it 'Invalid DateType adds a controlled vocabulary error' do
        expect(subject.errors.messages[:base]).to include("Invalid PBCore::AssetDate type: #{date_type}")
      end

      it 'Invalid Date value adds an error' do
        expect(subject.errors.messages[:base]).to include("Invalid PBCore::AssetDate value: #{date_value}")
      end

      context 'with no Titles' do
        let(:asset_titles) { [] }

        it 'adds an error' do
          expect(subject.errors.messages[:base]).to include("No PBCore::Title found")
        end
      end

      it 'Missing Title value adds an error' do
        expect(subject.errors.messages[:base]).to include("Invalid PBCore::Title, value attribute is missing")
      end
    end

    describe 'PBCore with valid data' do
      let(:asset_type) { "Raw Footage" }
      let(:asset_dates) { [ build(:pbcore_asset_date, type: "Broadcast"), build(:pbcore_asset_date, type: "Created") ] }
      let(:asset_titles) { [ build(:pbcore_title) ] }

      it 'is processed as valid' do
        expect(subject).to be_valid
      end
    end
  end
end