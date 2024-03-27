require 'rails_helper'

include Warden::Test::Helpers

RSpec.feature 'AssignRoleViewer.', js: true do
  context 'Add Viewer permissions to user (Role)' do
    let(:admin_user) { create :admin_user }
    let!(:user) { create :user }
    let!(:user_with_role) { create :user, role_names: ['TestRole'] }
    let!(:admin_set) { create :hyrax_admin_set }
    let!(:work) { create :asset_resource, :public, admin_set_id: admin_set.id }

    scenario 'Assign set of user (role) as Viewer to AdminSet' do
      admin_set.permission_manager.read_users = [user_with_role]
      admin_set.permission_manager.acl.save

      login_as(user_with_role)

      # Check records in search results
      visit '/'
      find("#search-submit-header").click
      expect(page).to have_content work.title[0]

      # open record in search result check it dont have other records edit permissions
      click_on(work.title[0])
      expect(page).not_to have_content 'Edit'
    end
  end
end
