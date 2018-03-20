require 'rails_helper'

include Warden::Test::Helpers

RSpec.feature 'AssignMultipleRolesAsViewer.', js: true do
  context 'Add Viewer permissions to user (Role)' do
    let(:admin_user) { create :admin_user }
    let!(:user) { create :user }
    let!(:user_with_role) { create :user_with_role, role_name: 'user' }
    let!(:admin_set_1) { create :admin_set, title: ["Test Admin Set 1"] }
    let!(:work_1) { create :public_work, title: ['First work'] }

    let!(:admin_set_2) { create :admin_set, title: ["Test Admin Set 2"] }
    let!(:work_2) { create :public_work, title: ['Second work'] }

    let!(:permission_template_1) { Hyrax::PermissionTemplate.find_or_create_by!(admin_set_id: admin_set_1.id) }
    let!(:permission_template_2) { Hyrax::PermissionTemplate.find_or_create_by!(admin_set_id: admin_set_2.id) }

    before do
      # For each test permission template, create a test workflow
      [permission_template_1, permission_template_2].each do |permission_template|
        Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template)
      end
    end

    scenario 'Assign set of user (role) as Viewer to AdminSet' do
      work_1.admin_set_id = admin_set_1.id
      work_1.save!
      Hyrax::PermissionTemplateAccess.create!(
          permission_template_id: permission_template_1.id,
          agent_type: 'group',
          agent_id: 'user',
          access: 'view'
      )

      work_2.admin_set_id = admin_set_2.id
      work_2.save!
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
      expect(page).to have_content work_1.title[0]

      # open record in search result check it dont have other records edit permissions
      click_on(work_1.title[0])
      expect(page).not_to have_content 'Edit'

      # Check second records in search results
      visit '/'
      find("#search-submit-header").click
      expect(page).to have_content work_2.title[0]

      # open record in search result check it dont have other records edit permissions
      click_on(work_2.title[0])
      expect(page).not_to have_content 'Edit'

      exit
    end
  end
end