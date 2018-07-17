require 'rails_helper'

RSpec.describe AdminData, type: :model do


  it "has level_of_user_access"
  it "has minimally_cataloged"
  it "has outside_url"
  it "has special_collection"
  it "has transcript_status"
  it "has sonnyci_id"
  it "has licensing_info"

  context "attributes" do
    let(:admin_data) { FactoryBot.build(:admin_data) }
    it "is valid with valid attributes" do
      expect(admin_data.valid?).to be true
    end
  end

  context "gid" do
    let(:admin_data) { FactoryBot.create(:admin_data) }
    it "has gid when created" do
      expect(admin_data.valid?).to be true
    end
  end
end
