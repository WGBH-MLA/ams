require 'rails_helper'

include Warden::Test::Helpers

RSpec.feature 'AssignUserroleAsViewerAndManager.', js: true do
  context 'Add permissions to user (Role)' do
    let(:admin_user) { create :admin_user }
    let!(:user) { create :user }
    let!(:user_with_role) { create :user, role_names: ['user'] }
    let!(:admin_set_1) { create :admin_set }
    let!(:admin_set_2) { create :admin_set }
    let!(:work_2) { create :asset, :public, user: user}
    let!(:permission_template_2) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_2.id) }
    let!(:workflow) { Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template_2) }

    scenario 'Assigning Permissions to AdminSets' do
      work_2.admin_set_id = admin_set_2.id
      work_2.save!
      Hyrax::PermissionTemplateAccess.create!(
          permission_template_id: permission_template_2.id,
          agent_type: 'group',
          agent_id: 'user',
          access: 'view'
      )

      login_as(admin_user)

      # Edit first AdminSet
      visit "/admin/admin_sets/#{admin_set_1.id}/edit"
      expect(page).to have_content 'Edit Administrative Set'

      # Add user as manager
      click_on('Participants')
      fill_in('permission_template_access_grants_attributes_0_agent_id', with: user_with_role.roles[0].name)
      find("#group-participants-form select option[value='manage']").select_option
      find('#group-participants-form .btn').click
      expect(page).to have_content  'participant rights have been updated'
      logout(admin_user)

      # Login role user to check permissions
      login_as(user_with_role)

      # Check first AdminSet edit permissions
      visit "/admin/admin_sets/#{admin_set_1.id}"
      expect(page).to have_content admin_set_1.title[0]
      click_on('Edit')
      expect(page).to have_content 'Edit Administrative Set'

      # Check second AdminSet records in search results
      visit '/'
      find("#search-submit-header").click
      expect(page).to have_content work_2.title[0]

      # open record in search result check it dont have other records edit permissions
      click_on(work_2.title[0])
      expect(page).not_to have_content 'Edit'
    end
  end
end
