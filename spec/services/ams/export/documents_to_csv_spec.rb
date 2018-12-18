require 'rails_helper'

RSpec.describe AMS::Export::DocumentsToCsv do
  subject { service }

  let(:asset) { create(:asset) }

  describe "#process_export" do
    describe "with 'asset' set as the object_type" do
      let(:service) do
        described_class.new([SolrDocument.new(asset.to_solr)], object_type: 'asset')
      end

      it "runs" do
        expect{ service.process_export }.to_not raise_error
      end
    end

    describe "with 'physical_instantiation' set as the object type" do
      let(:asset_with_physical_instantiation) { create(:asset, :with_physical_instantiation) }
      let(:service) do
        described_class.new([SolrDocument.new(asset.to_solr)], object_type: 'physical_instantiation')
      end

      it "runs" do
        expect{ service.process_export }.to_not raise_error
      end
    end

    describe "with an invalid object_type" do
      let(:invalid_object_service) do
        described_class.new([SolrDocument.new(asset.to_solr)], object_type: 'not_a_thing')
      end

      it "raises an error" do
        expect{ invalid_object_service.process_export }.to raise_error("Not a valid object_type for CSV export")
      end
    end

    describe "with no object_type" do
      let(:no_object_service) do
        described_class.new([SolrDocument.new(asset.to_solr)])
      end

      it "raises an error" do
        expect{ no_object_service.process_export }.to raise_error("Need to supply an object_type option for CSV export")
      end
    end
  end
end