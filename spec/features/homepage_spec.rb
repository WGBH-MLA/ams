require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Homepage.', js: false do
  context 'As a unauthenticated user' do
    scenario 'I can access the homepage.' do
      visit '/'
      expect(page).to have_css 'div.home-content'
    end
  end

  context 'As an authenticated user' do
    let(:user) { create(:user, email: 'leland_himself@example.com') }
    before { login_as user }
    scenario 'I can access the homepage.' do
      visit '/'
      expect(page).to have_css 'div.home-content'
    end
  end
end
