require 'rails_helper'

RSpec.describe "Pushes features", type: :controller, js: true do
  include Warden::Test::Helpers
  include Devise::Test::ControllerHelpers

  # let it bang
  let!(:user) { create :admin_user }
  let!(:asset) { create(:asset, user: user, program_title: ['foo']) }
  let!(:asset2) { create(:asset, user: user, program_title: ['foo bar']) }
  let!(:asset3) { create(:asset, user: user, needs_update: true) }

  # Login/logout before/after each test.
  before { login_as(user) }
  after { Warden.test_reset! }

  context '#pushes' do

    it 'gives validation error when invalid GUID input data' do
      visit '/pushes/new'
      bad_ids = [ 'blerg', 'cpb-aacip-11111111111' ]
      fill_in(id: 'id_field', with: bad_ids.join("\n") )
      expect(page).to have_text "The following IDs are not found"
      bad_ids.each do |bad_id|
        expect(page).to have_text bad_id
      end
    end

    it 'gives all clear for valid GUID input data' do
      visit '/pushes/new'
      fill_in(id: 'id_field', with: asset.id )
      expect(page).to have_text('All GUIDs are valid!')
    end

    it 'gets the correct record set for needs_updating' do
      # this i do
      # just for u
      visit '/pushes/needs_updating'
      expect(page.find('textarea')).to have_text(asset3.id)
    end

    it 'gets the correct record set when navigating from a catalog search' do
      # uri = %(/catalog?q=foo)
      # visit uri
      visit '/catalog'
      fill_in(id: 'q', with: 'foo')
      click_button(id: 'search-submit-header')
      click_link('Push To AAPB', class: 'aapb-push-button')

      expect(page.find('textarea')).to have_text(asset.id)
      expect(page.find('textarea')).to have_text(asset2.id)
    end

    it 'can submit a push successfully' do
      allow(PushToAAPBJob).to receive(:perform_later)
      visit '/pushes/new'
      fill_in('id_field', with: asset.id )
      click_button(id: 'push-submit')

      # this will have the output mail
      # output_mail = ActionMailer::Base.deliveries.last
      expect(PushToAAPBJob).to have_received(:perform_later)
      push = Push.last
      expect(push.user_id).to eq(user.id)
      expect(push.pushed_id_csv).to eq(asset.id)
    end
  end
end
