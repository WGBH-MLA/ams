require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Change password.', js: false do
  context 'As a logged in user' do
    let(:user) { create(:user, password: "password", password_confirmation: "password") }
    before { login_as user }
    scenario 'I can change my password' do
      visit '/'
      find('#user_utility_links a:contains("Change password")').click
      fill_in 'Password', with: 'password2'
      fill_in 'Password confirmation', with: 'password2'
      fill_in 'Current password', with: 'password'
      click_on 'Update'
      # Expect to return to the home page
      expect(page).to have_content 'Your account has been updated successfully.'
    end
  end
end
