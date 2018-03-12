require 'rails_helper'
include Warden::Test::Helpers

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

    let(:admin_set_1) do
      create(:admin_set, title: ['Bar'],
                         description: ['A substantial description'],
                         edit_users: [user.user_key])
    end
    let(:admin_set_2) { AdminSet.new }

    it 'i am admin ?' do
      expect(user).to be_a User
      expect(user.email).to_not be_nil
      expect(user.groups.include?('admin')).to be true
    end

    it 'i am admin_set_2, Not valid and already exist' do
      admin_set_2.title = ['Bar']
      admin_set_2.description = ['A substantial description']
      admin_set_2.edit_users = [user.user_key]
      expect(admin_set_2).to_not be_valid
    end
  end
end
