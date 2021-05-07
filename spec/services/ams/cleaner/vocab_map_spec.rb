require 'rails_helper'
require 'yaml'
require 'ams/cleaner/vocab_map'

RSpec.describe AMS::Cleaner::VocabMap do

  let(:config) { {
    "asset_type" => { "values" => { "Album" => "Album", "Clip" => "Clip", "Compilation" => "Compilation" } },
    "asset_date" => { "types" => { "broadcast" => "Broadcast", "air" => "Broadcast", "issue" => "Broadcast" } }
  } }

  before do
    allow(YAML).to receive(:load_file).and_return(config)
  end

  describe '.for_pbcore_element' do

    subject { described_class.for_pbcore_element(element) }

    context 'with an element that has a vocab map in the config' do
      let(:element) { create(:pbcore_asset_type) }

      it 'it maps a PBCoreElement to the correct config' do
        expect(subject).to eq(config["asset_type"])
      end
    end

    context 'with an element that does not have a vocab map in the config' do
      let(:element) { create(:pbcore_audience_level) }

      it 'returns nil' do
        expect(subject).to eq(nil)
      end
    end
  end

  describe '.for_pbcore_class' do

    subject { described_class.for_pbcore_class(pbcore_class) }

    context 'with a class that has a vocab map in the config' do
      let(:pbcore_class) { PBCore::AssetDate }

      it 'it maps a PBCoreClass to the correct config' do
        expect(subject).to eq(config["asset_date"])
      end
    end

    context 'with an element that does not have a vocab map in the config' do
      let(:pbcore_class) { PBCore::AudienceLevel }

      it 'returns nil' do
        expect(subject).to eq(nil)
      end
    end
  end
end