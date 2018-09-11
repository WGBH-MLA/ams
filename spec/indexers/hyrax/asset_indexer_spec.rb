require 'rails_helper'

RSpec.describe AssetIndexer do
  subject(:solr_document) { service.generate_solr_document }
  let(:service) { described_class.new(work) }
  let(:admin_data) { create(:admin_data) }
  let(:work) { build(:asset, with_admin_data:admin_data.gid, date:["2010"], broadcast_date:['2011-05'], copyright_date:['2011-05'], created_date:['2011-05-11']) }
  let(:asset) { create(:asset) }
  let(:asset_solr_doc) { described_class.new(asset) }
  let(:digital_instantiation_work) { create(:digital_instantiation) }
  let(:physical_instantiation_work) { create(:physical_instantiation) }

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

  context "dates" do
    it "has dates as daterange when any asset date attribute is present" do
      expect(work.date).to eq(['2010'])
      expect(work.broadcast_date).to eq(['2011-05'])
      expect(work.copyright_date).to eq(['2011-05'])
      expect(work.created_date).to eq(['2011-05-11'])
      expect(solr_document.fetch('date_drsim')).to eq work.date
      expect(solr_document.fetch('broadcast_date_drsim')).to eq work.broadcast_date
      expect(solr_document.fetch('copyright_date_drsim')).to eq work.copyright_date
      expect(solr_document.fetch('created_date_drsim')).to eq work.created_date
    end

    it "does not have dates as daterange when any asset date attribute is not present" do
      work.date = []
      work.broadcast_date = []
      work.copyright_date = []
      work.created_date = []
      solr_document = service.generate_solr_document
      expect(work.date).to be_empty
      expect(work.broadcast_date).to be_empty
      expect(work.copyright_date).to be_empty
      expect(work.created_date).to be_empty
      expect(solr_document.fetch('date_drsim')).to be_empty
      expect(solr_document.fetch('broadcast_date_drsim')).to be_empty
      expect(solr_document.fetch('copyright_date_drsim')).to be_empty
      expect(solr_document.fetch('created_date_drsim')).to be_empty
    end

    it "index child attributes into parent" do
      asset.ordered_members << digital_instantiation_work
      asset.ordered_members << physical_instantiation_work
      asset.save
      solr_doc = asset_solr_doc.generate_solr_document
      expect(solr_doc.fetch('media_type_ssim')).not_to be_empty

    end
  end
end