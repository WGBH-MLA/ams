require 'rails_helper'

RSpec.feature 'AssignMultipleRolesAsViewer.', js: true do
  context 'Add Viewer permissions to user (Role)' do
    let(:admin_user) { create :admin_user }
    let!(:user) { create :user }
    let!(:user_with_role) { create :user, role_names: ['test-role'] }
    let!(:admin_set_1) { create :hyrax_admin_set }
    let!(:asset_resource_1) { create :asset_resource, :public, depositor: user.user_key, admin_set_id: admin_set_1.id}
    let!(:admin_set_2) { create :hyrax_admin_set }
    let!(:asset_resource_2) { create :asset_resource, :public, depositor: user.user_key, admin_set_id: admin_set_2.id}

    before do
      admin_set_1.permission_manager.read_users = [user_with_role]
      admin_set_1.permission_manager.acl.save
      admin_set_2.permission_manager.read_users = [user_with_role]
      admin_set_2.permission_manager.acl.save
    end

    scenario 'Assign set of user (role) as Viewer to AdminSet' do
      login_as(user_with_role)

      # Check first records in search results
      visit '/'
      find("#search-submit-header").click
      expect(page).to have_content asset_resource_1.title[0]

      # open record in search result check it dont have other records edit permissions
      click_on(asset_resource_1.title[0])
      expect(page).not_to have_content 'Edit'

      # Check second records in search results
      visit '/'
      find("#search-submit-header").click
      expect(page).to have_content asset_resource_2.title[0]

      # open record in search result check it dont have other records edit permissions
      click_on(asset_resource_2.title[0])
      expect(page).not_to have_content 'Edit'
    end
  end
end
