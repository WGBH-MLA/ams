require 'rails_helper'

include Warden::Test::Helpers

RSpec.feature 'AssignRoleViewer.', js: true do
  context 'Add Viewer permissions to user (Role)' do
    let(:admin_user) { create :admin_user }
    let!(:user) { create :user }
    let!(:user_with_role) { create :user, role_names: ['TestRole'] }
    let!(:admin_set) { create :admin_set }
    let!(:work) { create :asset, :public, admin_set_id: admin_set.id }

    let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set.id) }
    let(:workflow) { Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template) }

    scenario 'Assign set of user (role) as Viewer to AdminSet' do
      work.admin_set_id = admin_set.id
      work.save!

      Hyrax::PermissionTemplateAccess.create!(
        permission_template_id: permission_template.id,
        agent_type: 'group',
        agent_id: 'TestRole',
        access: 'view'
      )
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
