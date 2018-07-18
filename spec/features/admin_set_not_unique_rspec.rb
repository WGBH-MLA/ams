require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'admin user' do
    let(:user_attributes) do
      { email: 'wgbh_admin@wgbh.org' }
    end
    let(:user) do
      User.new(user_attributes) { |u| u.save(validate: false) }
    end

    before do
      AdminSet.find_or_create_default_admin_set_id
      login_as user
    end

    let(:admin_set_1) { create(:admin_set, edit_users: [user.user_key]) }
    let(:admin_set_2) { create(:admin_set) }

    it 'i am admin ?' do
      expect(user).to be_a User
      expect(user.email).to_not be_nil
      expect(user.groups.include?('admin')).to be true
    end

    it 'i am admin_set_2, Not valid and already exist' do
      admin_set_2.title = admin_set_1.title
      expect(admin_set_2).to_not be_valid
    end
  end
end
