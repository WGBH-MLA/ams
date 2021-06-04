require 'rails_helper'
require 'ams/cleaner/pbcore_element_editor'

RSpec.describe AMS::Cleaner::Steps do

  describe '.process' do

    let(:pbcore) { build(:pbcore_description_document, :full_aapb) }

    context 'CleanAssetTypes' do

      subject { AMS::Cleaner::Steps::CleanAssetTypes.process(pbcore) }
      let(:asset_types) { pbcore.asset_types }
      let(:new_value) { SecureRandom.hex.slice(0..7) }

      before do
        allow_any_instance_of(AMS::Cleaner::PBCoreElementEditor).to receive(:value).and_return(new_value)
      end

      it 'sets pbcore asset_types values' do
        expect(subject.asset_types.length).to eq(asset_types.length)
        expect(subject.asset_types.map(&:value).uniq).to eq([new_value])
      end
    end

    context 'CleanDateTypes' do

      subject { AMS::Cleaner::Steps::CleanDateTypes.process(pbcore) }
      let(:asset_dates) { pbcore.asset_dates }
      let(:new_type) { SecureRandom.hex.slice(0..7) }

      before do
        allow_any_instance_of(AMS::Cleaner::PBCoreElementEditor).to receive(:type).and_return(new_type)
      end

      it 'sets pbcore asset_dates types' do
        expect(subject.asset_dates.length).to eq(asset_dates.length)
        expect(subject.asset_dates.map(&:type).uniq).to eq([new_type])
      end
    end

    context 'CleanAssetDescriptionTypes' do

      subject { AMS::Cleaner::Steps::CleanAssetDescriptionTypes.process(pbcore) }
      let(:descriptions) { pbcore.descriptions }
      let(:new_type) { SecureRandom.hex.slice(0..7) }

      before do
        allow_any_instance_of(AMS::Cleaner::PBCoreElementEditor).to receive(:type).and_return(new_type)
      end

      it 'sets pbcore descriptions types' do
        expect(subject.descriptions.length).to eq(descriptions.length)
        expect(subject.descriptions.map(&:type).uniq).to eq([new_type])
      end
    end

    context 'DeleteEmptyTitles' do

      subject { AMS::Cleaner::Steps::DeleteEmptyTitles.process(pbcore) }
      let(:pbcore) { build(:pbcore_description_document, :full_aapb, titles: [ build(:pbcore_title, type: '', value: ''), build(:pbcore_title, value: test_title) ]) }
      let(:test_title) { SecureRandom.hex.slice(0..7) }

      it 'removes pbcore titles with no values' do
        expect(subject.titles.map(&:value)).to eq([test_title])
      end
    end

    context 'AddUnknownTitleIfMissing' do

      subject { AMS::Cleaner::Steps::AddUnknownTitleIfMissing.process(pbcore) }
      let(:pbcore) { build(:pbcore_description_document, :full_aapb, titles: []) }

      it 'adds pbcore title with unknown type and value if no titles are present' do
        expect(subject.titles.length).to eq(1)
        expect(subject.titles.map(&:type)).to eq(["unknown"])
        expect(subject.titles.map(&:value)).to eq(["unknown"])
      end
    end

  end
end
