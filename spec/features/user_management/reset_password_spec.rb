require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Reset password.', js: false do
  context 'As a logged in user' do
    let(:user) { create(:user, password: "password", password_confirmation: "password") }
    let(:most_recent_email) { ActionMailer::Base.deliveries.last }
    let(:password_reset_link) { Capybara::Node::Simple.new(most_recent_email.body.raw_source).find('a')['href'] }
    before { logout }
    scenario 'I can request instruction on how to reset my password' do
      visit '/'
      click_on 'Login'
      click_on 'Forgot your password?'
      fill_in 'Email', with: user.email
      click_on 'Send me reset password instructions'

      expect(most_recent_email.to).to eq [user.email]
      expect(most_recent_email.from).to eq [Devise.mailer_sender]

      visit password_reset_link

      fill_in 'New password', with: 'password2'
      fill_in 'Confirm new password', with: 'password2'
      click_on 'Change my password'

      expect(page).to have_content 'Your password has been changed successfully. You are now signed in.'
    end
  end
end
