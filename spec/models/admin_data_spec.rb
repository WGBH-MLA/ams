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
end
