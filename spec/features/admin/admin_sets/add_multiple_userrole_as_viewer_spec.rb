require 'rails_helper'

RSpec.feature 'AssignMultipleRolesAsViewer.', js: true do
  context 'Add Viewer permissions to user (Role)' do
    let(:admin_user) { create :admin_user }
    let!(:user) { create :user }
    let!(:user_with_role) { create :user, role_names: ['test-role'] }
    let!(:admin_set_1) { create :admin_set }
    let!(:asset_1) { create :asset, :public, user: user, admin_set_id: admin_set_1.id}
    let!(:admin_set_2) { create :admin_set }
    let!(:asset_2) { create :asset, :public, user: user, admin_set_id: admin_set_2.id}

    let!(:permission_template_1) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_1.id) }
    let!(:permission_template_2) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_2.id) }

    before do
      # For each test permission template, create a test workflow
      [permission_template_1, permission_template_2].each do |permission_template|
        Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template)
      end
    end

    scenario 'Assign set of user (role) as Viewer to AdminSet' do
      # asset_1.admin_set_id = admin_set_1.id
      # asset_1.save!
      Hyrax::PermissionTemplateAccess.create!(
          permission_template_id: permission_template_1.id,
          agent_type: 'group',
          agent_id: 'user',
          access: 'view'
      )

      # asset_2.admin_set_id = admin_set_2.id
      # asset_2.save!
      Hyrax::PermissionTemplateAccess.create!(
          permission_template_id: permission_template_2.id,
          agent_type: 'group',
          agent_id: 'user',
          access: 'view'
      )

      login_as(user_with_role)

      # Check first records in search results
      visit '/'
      find("#search-submit-header").click
      expect(page).to have_content asset_1.title[0]

      # open record in search result check it dont have other records edit permissions
      click_on(asset_1.title[0])
      expect(page).not_to have_content 'Edit'

      # Check second records in search results
      visit '/'
      find("#search-submit-header").click
      expect(page).to have_content asset_2.title[0]

      # open record in search result check it dont have other records edit permissions
      click_on(asset_2.title[0])
      expect(page).not_to have_content 'Edit'
    end
  end
end
