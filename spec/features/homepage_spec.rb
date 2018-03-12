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

    let(:user_attributes) do
      { email: 'archivist2@example.com' }
    end
    let(:user) do
      User.new(user_attributes) { |u| u.save(validate: false) }
    end

    before do
      AdminSet.find_or_create_default_admin_set_id
      login_as user
    end

    scenario 'I can access the homepage.' do
      visit '/'
      expect(page).to have_css 'div.home-content'
    end
  end
end
