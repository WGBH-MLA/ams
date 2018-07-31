require 'rails_helper'

RSpec.describe AssetIndexer do
  subject(:solr_document) { service.generate_solr_document }
  let(:service) { described_class.new(work) }
  let(:admin_data) { create(:admin_data) }
  let(:work) { build(:asset, with_admin_data:admin_data.gid) }

  context "indexes admin data" do
    it "indexes the correct fields" do
      expect(solr_document.fetch('admin_data_tesim')).to eq admin_data.gid
      expect(solr_document.fetch('level_of_user_access_tesim')).to eq admin_data.level_of_user_access
      expect(solr_document.fetch('minimally_cataloged_tesim')).to eq admin_data.minimally_cataloged
      expect(solr_document.fetch('outside_url_tesim')).to eq admin_data.outside_url
      expect(solr_document.fetch('special_collection_tesim')).to eq admin_data.special_collection
      expect(solr_document.fetch('transcript_status_tesim')).to eq admin_data.transcript_status
      expect(solr_document.fetch('sonyci_id_tesim')).to eq admin_data.sonyci_id
      expect(solr_document.fetch('licensing_info_tesim')).to eq admin_data.licensing_info
    end
  end

  context "thumbnail" do
    it "has work_type.png as default thumbnail when work.thumbnail_id is null" do
      expect(work.thumbnail_id).to be_nil
      work_type = solr_document.fetch('has_model_ssim').first.downcase
      default_image = ActionController::Base.helpers.image_path(work_type+'.png')
      expect(solr_document.fetch('thumbnail_path_ss')).to eq default_image
    end
  end
end