require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'AdminCreateUser.', js: false do


  context 'an admin user' do
    let(:admin_user) { create :admin_user }

    before do
      login_as(admin_user, scope: :user, run_callbacks: false)
    end

    scenario do
      visit '/admin/users/new'
      expect(page.status_code).to eq(200)
      expect(page).to have_selector(:css, 'a[href="/admin/users/new?locale=en"]')
      expect(page).to have_field('Email')
      expect(page).to have_field('Password')
    end
  end


  context 'an authenticated user' do
    let(:user) { create :user }

    before do
      login_as(user, scope: :user, run_callbacks: false)
    end

    scenario do
      visit '/admin/users/new'
      expect(page.status_code).to eq(200)
      expect(page).not_to have_selector(:css, 'a[href="/admin/users/new?locale=en"]')
      expect(current_path).to eq(root_path)
      expect(page).to have_content('Not authorized to create users.')
    end
  end


  context 'a non-authenticated user' do
    scenario do
      visit '/admin/users/new'
      expect(current_path).to eq(new_user_session_path)
      expect(page).to have_css('div.alert')
    end
  end
end
