require 'rails_helper'

RSpec.describe AMS::Export::Delivery do
  describe '.for_export_type' do
    subject { described_class.for_export_type(export_type) }

    context 'with "asset"' do
      let(:export_type) { 'asset' }
      it { is_expected.to eq AMS::Export::Delivery::S3Delivery }
    end

    context 'with "digtial_instantiation"' do
      let(:export_type) { 'digital_instantiation' }
      it { is_expected.to eq AMS::Export::Delivery::S3Delivery }
    end

    context 'with "physical_isntantiation"' do
      let(:export_type) { 'physical_instantiation' }
      it { is_expected.to eq AMS::Export::Delivery::S3Delivery }
    end

    context 'with "pbcore_zip"' do
      let(:export_type) { 'pbcore_zip' }
      it { is_expected.to eq AMS::Export::Delivery::S3Delivery }
    end

    context 'with "push_to_aapb"' do
      let(:export_type) { 'push_to_aapb' }
      it { is_expected.to eq AMS::Export::Delivery::AAPBDelivery }
    end
  end
end
