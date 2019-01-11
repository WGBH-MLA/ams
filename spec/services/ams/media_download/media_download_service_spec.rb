require 'rails_helper'

RSpec.describe AMS::MediaDownload::MediaDownloadService do
  subject { service }

  let(:admin_data) { create(:admin_data, :one_sony_ci_id) }
  let(:asset_with_digital_instantiation) { create(:asset, :with_digital_instantiation_and_essence_track, with_admin_data: admin_data.gid) }
  let(:fake_sony_ci_url) { "https://fake_sony_ci_url/cifiles/94d6ac5516bd4656864e71c233f63c0d/cpb-aacip-15-hd7np1wp4c__barcode163700_.h264.mp4?AWSAccessKeyId=XXXXXXXXXXXXXXXXXXXX&Expires=0000000000&response-content-disposition=attachment%3B%20filename%3D%22cpb-aacip-15-hd7np1wp4c__barcode163700_.h264.mp4%22&response-content-type=application%2F&et=download"}
  let(:spec_media_file_path) { File.join(Rails.root, 'spec', 'fixtures', 'cpb-aacip-15-hd7np1wp4c__barcode163700_.h264.mp4' ) }
  let(:fake_sony_ci_api) { instance_double("SonyCiBasic") }
  let(:solr_doc) { SolrDocument.new(asset_with_digital_instantiation.to_solr) }

  # This one should fail since it has two DigitalInstantiations but only one Sony Ci ID from AdminData
  let(:asset_with_two_digital_instantiations_one_sony_ci) { create(:asset, :with_two_digital_instantiations_and_essence_tracks, with_admin_data: admin_data.gid) }
  let(:invalid_solr_doc) { SolrDocument.new(asset_with_two_digital_instantiations_one_sony_ci.to_solr) }

  before do
    allow(fake_sony_ci_api).to receive(:download).with(/^Sony-\d/).and_return(fake_sony_ci_url)
    allow(service).to receive(:ci).and_return(fake_sony_ci_api)
    allow(service).to receive(:generate_sonyci_file_path).with('cpb-aacip-15-hd7np1wp4c__barcode163700_.h264.mp4').and_return(spec_media_file_path)
    allow(service).to receive(:download_media_file).with(spec_media_file_path, fake_sony_ci_url)
    allow(service).to receive(:delete_media_files)
  end

  describe "#process" do
    context "with one Sony Ci ID and one DigitalInstantiation" do
      let(:service) do
        described_class.new(solr_doc)
      end

      it "runs" do
        #  For yield matchers the expect block must accept an argument that is then passed
        # on to the method-under-test as a block. This acts as a "probe" that allows the
        # matcher to detect whether or not your method yields, and, if so, how many times
        # and what the yielded arguments are.
        expect { |b| service.process(&b) }.to yield_with_no_args
      end
    end

    context "with one Sony Ci ID and two DigitalInstantiations" do
      let(:service) do
        described_class.new(invalid_solr_doc)
      end

      it "raises a DigitalInstation with no Sony Ci ID error" do
        #  For yield matchers the expect block must accept an argument that is then passed
        # on to the method-under-test as a block. This acts as a "probe" that allows the
        # matcher to detect whether or not your method yields, and, if so, how many times
        # and what the yielded arguments are.
        expect{ service.process }.to raise_error(/Instantiation is missing a SonyCi Identifier./)
      end

    end
  end
end