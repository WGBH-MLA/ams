require 'rails_helper'

RSpec.feature 'Add "manage" permissions to test role', js: true, clean:true do
  let!(:admin_user) { create :admin_user }
  let!(:user) { create :user, role_names: ['test_role'] }
  let!(:admin_set) { create(:hyrax_admin_set, with_permission_template: true ) }
  let!(:asset_resource) { create(:asset_resource, :public, user: user, admin_set: admin_set) }

  scenario 'Assigning Permissions to AdminSets' do
    login_as(admin_user)

    # Edit first AdminSet
    visit "/admin/admin_sets/#{admin_set.id}/edit"
    expect(page).to have_content 'Edit Administrative Set'

    # Add user as manager
    click_on('Participants')
    # Choose the custom role we created when creating the user.
    fill_in('permission_template_access_grants_attributes_0_agent_id', with: user.roles[0].name)
    # Select the "manage" option
    find("#group-participants-form select option[value='manage']").select_option
    # Save the changes.
    find('#group-participants-form .btn').click
    # Check for the confirmation flash message.
    expect(page).to have_content  'participant rights have been updated'

    # Now logout the admin user, and log in as the non-admin user we created.
    logout(admin_user)
    login_as(user)

    # Check first AdminSet edit permissions
    visit "/admin/admin_sets/#{admin_set.id}"
    expect(page).to have_content admin_set.title[0]
    click_on('Edit')
    expect(page).to have_content 'Edit Administrative Set'

    # Now ensure that the AssetResource we created as part of the custom admin set is
    # returned in search results.
    visit '/'

    find("#search-submit-header").click

    expect(page).to have_content asset_resource.title[0]

    # open record in search result check it dont have other records edit permissions
    click_on(asset_resource.title[0])
    expect(page).not_to have_content 'Edit'
  end
end
