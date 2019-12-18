require 'rails_helper'

RSpec.describe AMS::Export::DocumentsToCsv do
  subject { service }

  let(:asset) { create(:asset) }
  let(:search_results) { [SolrDocument.new(asset.to_solr)] }

  describe "#process_export" do
    describe "with 'asset' set as the object_type" do
      let(:service) do
        described_class.new(search_results, object_type: 'asset')
      end

      it "runs" do
        expect{ service.process_export }.to_not raise_error
      end
    end

    describe "with 'physical_instantiation' set as the object type" do
      let(:asset_with_physical_instantiation) { create(:asset, :with_physical_instantiation) }
      let(:service) do
        described_class.new(search_results, object_type: 'physical_instantiation', export_type: 'csv_download')
      end

      it "runs" do
        expect{ service.process_export }.to_not raise_error
      end
    end

    describe "with an invalid object_type" do
      let(:invalid_object_service) do
        described_class.new(search_results, object_type: 'not_a_thing', export_type: 'csv_download')
      end

      it "raises an error" do
        expect{ invalid_object_service.process_export }.to raise_error("Not a valid object_type for CSV export")
      end
    end

    describe "with no object_type" do
      let(:no_object_service) do
        described_class.new(search_results, object_type: nil, export_type: 'csv_download')
      end

      it "raises an error" do
        expect{ no_object_service }.to raise_error "Not a valid object_type for CSV export"
      end
    end


    describe "with no export_type" do
      let(:no_type_service) do
        described_class.new(search_results, object_type: nil)
      end

      it "raises an error" do
        expect{ no_type_service }.to raise_error "export_type was not defined!"
      end
    end

  end
end
