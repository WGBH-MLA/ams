require 'rails_helper'

RSpec.describe AMS::Export::Search do
  describe '.for_export_type' do
    subject { described_class.for_export_type(export_type) }

    context 'with "asset"' do
      let(:export_type) { 'asset' }
      it { is_expected.to eq AMS::Export::Search::CatalogSearch }
    end

    context 'with "physical_instantiation"' do
      let(:export_type) { 'physical_instantiation' }
      it { is_expected.to eq AMS::Export::Search::PhysicalInstantiationsSearch }
    end

    context 'with "digital_instantiation"' do
      let(:export_type) { 'digital_instantiation' }
      it { is_expected.to eq AMS::Export::Search::DigitalInstantiationsSearch }
    end
  end
end
