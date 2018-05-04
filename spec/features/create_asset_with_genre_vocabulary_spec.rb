require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Create Asset with Asset Type', js: true, include: :asset_form_helpers do
  context 'Create adminset, create asset' do
    let(:admin_user) { create :admin_user }
    let!(:user_with_role) { create :user_with_role, role_name: 'user' }

    let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
    let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(admin_set_id: admin_set_id) }
    let(:workflow) { Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template) }

    let(:asset_attributes) do
      { title: "My Asset Test Title", description:"My Asset Test Description", genre:"Call-in" }
    end

    before do
      # Create a single action that can be taken
      Sipity::WorkflowAction.create!(name: 'submit', workflow: workflow)

      # Grant the user access to deposit into the admin set.
      Hyrax::PermissionTemplateAccess.create!(
          permission_template_id: permission_template.id,
          agent_type: 'user',
          agent_id: user_with_role.user_key,
          access: 'deposit'
      )
      login_as user_with_role
    end

    scenario 'Create Asset with Asset Type' do
      # create asset
      visit '/'
      click_link "Share Your Work"
      choose "payload_concern", option: "Asset"
      click_button "Create work"

      expect(page).to have_content "Add New Asset"

      click_link "Files" # switch tab
      expect(page).to have_content "Add files"
      expect(page).to have_content "Add folder"

      # validate metadata with errors
      page.find("#required-metadata")[:class].include?("incomplete")

      click_link "Descriptions" # switch tab
      fill_in_title asset_attributes[:title] # see AssetFormHelpers#fill_in_title
      fill_in('Description', with: asset_attributes[:description])

      # validated metadata without errors
      page.find("#required-metadata")[:class].include?("complete")

      click_link "Additional fields" # additional metadata

      # Select genre
      select = page.find('select#asset_genre')
      select.select asset_attributes[:genre]

      click_link "Relationships" # define adminset relation
      find("#asset_admin_set_id option[value='#{admin_set_id}']").select_option

      click_on('Save')

      visit '/'
      find("#search-submit-header").click

      # expect assets is showing up
      expect(page).to have_content asset_attributes[:title]

      # open asset with detail show
      click_on(asset_attributes[:title])
      expect(page).to have_content asset_attributes[:genre]
    end
  end
end