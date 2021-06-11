require 'rails_helper'

RSpec.describe AMS::MediaDownload::MediaDownloadService do
  subject { service }

  let(:admin_data) { create(:admin_data, :one_sony_ci_id) }
  let(:asset) { create(:asset, with_admin_data: admin_data.gid) }
  let(:fake_sony_ci_url) { "https://fake_sony_ci_url/cifiles/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/cpb-aacip-15-hd7np1wp4c__barcode163700_.h264.mp4?response-content-disposition=attachment%3bfilename%3d%22cpb-aacip-15-hd7np1wp4c__barcode163700_.h264.mp4"}
  let(:spec_media_file_path) { File.join(Rails.root, 'spec', 'fixtures', 'cpb-aacip-15-hd7np1wp4c__barcode163700_.h264.mp4' ) }
  let(:fake_sony_ci_api) { instance_double("SonyCiBasic") }
  let(:solr_doc) { SolrDocument.new(asset.to_solr) }

  let(:service) do
    described_class.new(solr_document: solr_doc)
  end

  before do
    allow(service).to receive(:ci).and_return(fake_sony_ci_api)
    allow(service).to receive(:generate_sonyci_file_path).with('cpb-aacip-15-hd7np1wp4c__barcode163700_.h264.mp4').and_return(spec_media_file_path)
    allow(service).to receive(:download_media_file).with(spec_media_file_path, fake_sony_ci_url)
    allow(service).to receive(:delete_media_files)
  end

  describe "#process" do
    context "with a single Sony Ci ID" do
      context "during a successful download" do
        before do
          allow(fake_sony_ci_api).to receive(:download).with(/Sony-\d{1}/).and_return(fake_sony_ci_url)
        end

        it "returns the expected Success object" do
          result = service.process
          expect(result).to be_a(AMS::MediaDownload::MediaDownloadService::Success)
          expect(result[:filename]).to match(/(export-)\d{2}_\d{2}_\d{4}_\d{2}:\d{2}.zip/)
          expect(result[:file_path].path).to match(/(export-)\d{2}_\d{2}_\d{4}_\d{2}:\d{2}.zip/)
          expect(result[:file_path]).to be_a(Tempfile)
        end
      end

      context "during an unsuccessful download" do
        before do
          allow(fake_sony_ci_api).to receive(:download).with(/Sony-\d{1}/).and_raise(RuntimeError.new("NO VIDEO!!!"))
        end

        it "returns the expected Failure object" do
          result = service.process
          expect(result).to be_a(AMS::MediaDownload::MediaDownloadService::Failure)
          expect(result[:errors].length).to eq(1)
          expect(result[:errors].first).to be_a_kind_of(RuntimeError)
        end
      end
    end
  end
end
