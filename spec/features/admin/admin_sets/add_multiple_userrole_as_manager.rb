require 'rails_helper'

include Warden::Test::Helpers

RSpec.feature 'AssignMultipleRolesAsManager.', js: true do
    context 'Add Manager permissions to user (Role)' do
      let(:admin_user) { create :admin_user }
      let!(:user) { create :user }
      let!(:user_with_role) { create :user_with_role, role_name: 'user' }
      let!(:admin_set_1) { create :admin_set }
      let!(:admin_set_2) { create :admin_set }

      before do
        login_as(admin_user)
      end

      scenario 'Assign set of user (role) as Manager to multiple AdminSet' do

        # Edit first AdminSet
        visit "/admin/admin_sets/#{admin_set_1.id}/edit"
        expect(page).to have_content 'Edit Administrative Set'

        # Add participants
        click_on('Participants')
        fill_in('permission_template_access_grants_attributes_0_agent_id', with: user_with_role.roles[0].name)
        find("#group-participants-form select option[value='manage']").select_option
        find('#group-participants-form .btn').click
        expect(page).to have_content  'participant rights have been updated'


        # Edit AdminSet
        visit "/admin/admin_sets/#{admin_set_2.id}/edit"
        expect(page).to have_content 'Edit Administrative Set'

        # Add participants
        click_on('Participants')
        fill_in('permission_template_access_grants_attributes_0_agent_id', with: user_with_role.roles[0].name)
        find("#group-participants-form select option[value='manage']").select_option
        find('#group-participants-form .btn').click
        expect(page).to have_content  'participant rights have been updated'

        # Login manager role user to check permissions
        logout(admin_user)
        login_as(user_with_role)

        # Open and Edit first AdminSet
        visit "/admin/admin_sets/#{admin_set_1.id}"
        expect(page).to have_content admin_set_1.title[0]
        click_on('Edit')
        expect(page).to have_content 'Edit Administrative Set'

        # Open and Edit second AdminSet
        visit "/admin/admin_sets/#{admin_set_2.id}"
        expect(page).to have_content admin_set_2.title[0]
        click_on('Edit')
        expect(page).to have_content 'Edit Administrative Set'

        # Login other user to check permissions
        logout(user_with_role)
        login_as(user)

        # Check other user AdminSet permissions exist
        visit '/admin/admin_sets'
        expect(page).to have_content 'You are not authorized to access this page.'

        exit
      end
    end

  end