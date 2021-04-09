require 'rails_helper'
require 'pbcore'
require 'ams/cleaner/pbcore_element_editor'

RSpec.describe AMS::Cleaner::PBCoreElementEditor do

  let(:pbcore_editor) { described_class.new(element: element) }

  let(:config) { {
    "title" => { "values" => { "test value" => "Test Value" }, "types" => { "test type" => "Test Type" } },
    "asset_date" => { "types" => { "" => "Date" } }
  } }

  before do
    allow(YAML).to receive(:load_file).and_return(config)
  end

  context 'with a PBCore element that has a VocabMap for both value and type' do
    let(:element) { build(:pbcore_title, value: 'test value', type: 'test type') }

    describe '.value' do
      it 'returns a mapped element value' do
        expect(pbcore_editor.value).to eq('Test Value')
      end
    end

    describe '.type' do
      it 'returns a mapped element type' do
        expect(pbcore_editor.type).to eq('Test Type')
      end
    end
  end

  context 'with a PBCore element with a nil type and a VocabMap for an empty string' do
    let(:element) { build(:pbcore_asset_date, type: nil)  }

    describe '.type' do
      it 'returns a mapped element type' do
        expect(pbcore_editor.type).to eq('Date')
      end
    end
  end

  context 'with a PBCore element with no VocabMap' do
    let(:element) { build(:pbcore_description, type: type, value: value) }
    let(:type) { SecureRandom.hex.slice(0..7) }
    let(:value) { SecureRandom.hex.slice(0..7) }

    describe '.type' do
      it 'returns the original type' do
        expect(pbcore_editor.type).to eq(type)
      end
    end

    describe '.value' do
      it 'returns the original value' do
        expect(pbcore_editor.value).to eq(value)
      end
    end
  end
end