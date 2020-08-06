require 'rails_helper'

RSpec.describe AdminData, type: :model do

  context "attributes" do
    let(:admin_data) { FactoryBot.build(:admin_data) }
    it "is valid with valid attributes" do
      expect(admin_data.valid?).to be true
    end
  end

  context "gid" do
    let(:admin_data) { FactoryBot.create(:admin_data) }
    let(:expected_admin_data_gid) {URI::GID.build(app: GlobalID.app, model_name: :admindata, model_id: admin_data.id).to_s}
    it "has gid when created" do
      expect(admin_data.gid).to eq(expected_admin_data_gid)
    end
  end

  context 'when it has an associated Fedora object and Solr document (as it always should)' do
    let!(:asset) { create(:asset) }
    let(:admin_data) { AdminData.find_by_gid(asset.admin_data_gid) }

    describe '#solr_doc' do
      it 'returns the solr document' do
        # Expect the Solr doc ID to be the same as the Asset ID
        expect(admin_data.solr_doc.id).to eq asset.id
        # Expect the AdminData gid to be teh same as what's in the returned
        # solr doc.
        expect(admin_data.solr_doc[:admin_data_gid_ssim].first).to eq admin_data.gid
      end
    end

    describe '#asset' do
      it 'returns the asset' do
        expect(admin_data.asset).to eq asset
      end
    end
  end
end
