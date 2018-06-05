require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'factory :user with default values' do
    # let(:user) { create(:user, :guest) }
    let(:user) { create(:user) }
    it 'creates a User object with default values' do
      expect(user).to be_a User
      expect(user.email).to_not be_nil
      expect(user.guest).to be true
    end
  end

  describe 'factory :admin_user with default values' do
    let(:admin_user) { create(:admin_user) }

    it 'i am admin ?' do
      expect(admin_user).to be_a User
      expect(admin_user.email).to_not be_nil
      expect(admin_user.groups.include?('admin')).to be true
    end
  end
end
