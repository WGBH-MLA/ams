require 'rails_helper'

include Warden::Test::Helpers

RSpec.feature 'AdminDisableUserAccounts.', js: true do


  user_attributes = { "email" => "email-#{srand}@test.com", "password" => (0...8).map { (65 + rand(26)).chr }.join }


  context 'Admin Manage Users' do
    let(:admin_user) { create :admin_user }

    before do
      login_as(admin_user)
    end

    scenario 'Disable User Account' do
      visit '/admin/users/new'
      expect(page).to have_field('Email')
      fill_in('Email', with: user_attributes["email"] )
      fill_in('Password', with: user_attributes["password"] )
      fill_in('user_password_confirmation', with: user_attributes["password"] )
      click_on('Create')
      accept_confirm do
        find('tr', text: user_attributes["email"]).click_link(I18n.t('admin.users.index.disable'))
      end
      expect(page).to have_content I18n.t('admin.users.index.disabled')
      visit destroy_user_session_path
      visit new_user_session_path
      fill_in('Email', with: user_attributes["email"] )
      fill_in('Password', with: user_attributes["password"] )
      click_on('Log in')
      expect(page).to have_content I18n.t('devise.sessions.user.account_deactivated')
    end
  end
end
