require 'rails_helper'

RSpec.feature 'AdminAddUserroleAsAdminsetManager.', js: true do

  context 'As Admin add a UserRole as Adminset Manager' do
    let(:admin_user) { create :admin_user }
    let!(:user) { create :user }
    let!(:user_with_role) { create :user, role_names: ['test_role'] }
    let!(:admin_set) { create :admin_set }
    let(:route) { "/admin/admin_sets/#{admin_set.id}?locale=en" }

    before do
      login_as(admin_user)
    end

    scenario 'Assign set of user (role) as Manager to AdminSet' do
      skip 'TODO fix feature specs'

      # Check AdminSet exist
      visit 'dashboard/collections'
      expect(page).to have_content admin_set.title[0]

      # Open AdminSet and edit
      find("a[href='#{route}']").click
      click_on('Edit')
      expect(page).to have_content 'Edit Administrative Set'

      # Add participants
      click_on('Participants')
      fill_in('permission_template_access_grants_attributes_0_agent_id', with: user_with_role.groups.first)
      find("#group-participants-form select option[value='manage']").select_option
      find('#group-participants-form .btn').click
      expect(page).to have_content  'participant rights have been updated'

      # Login manager role user to check permissions
      visit destroy_user_session_path
      login_as(user_with_role)

      # Check AdminSet permissions exist
      visit 'dashboard/collections'
      expect(page).to have_content admin_set.title[0]

      # Open AdminSet and edit
      find("a[href='#{route}']").click
      click_on('Edit')
      expect(page).to have_content 'Edit Administrative Set'

      # Login other user to check permissions
      visit destroy_user_session_path
      login_as(user)

      # Check other user AdminSet permissions exist
      visit 'dashboard/collections'
      expect(page).to have_content '0 collections you can manage in the repository'
    end
  end
end
