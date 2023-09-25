require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Create AssetResource with AssetResource Type', js: true, asset_resource_form_helpers: true, clean:true do
  context 'Create adminset, create asset_resource' do
    let(:admin_user) { create :admin_user }
    let!(:user_with_role) { create :user, role_names: ['ingester'] }

    let(:admin_set) { Hyrax::AdminSetCreateService.find_or_create_default_admin_set }

    let(:asset_resource_attributes) do
      { title: "My AssetResource Test Title"+ get_random_string, description: "My AssetResource Test Description", asset_resource_type: "Album" }
    end

    before do
      admin_set.permission_manager.edit_users = [user_with_role.user_key]
      admin_set.permission_manager.acl.save
      login_as user_with_role
    end

    scenario 'Create AssetResource with AssetResource Type' do
      skip 'TODO fix feature specs'
      # create asset_resource
      visit new_hyrax_asset_resource_path

      expect(page).to have_content "Add New AssetResource"

      click_link "Files" # switch tab
      expect(page).to have_content "Add files"
      expect(page).to have_content "Add folder"

      # validate metadata with errors
      page.find("#required-metadata")[:class].include?("incomplete")

      click_link "Descriptions" # switch tab

      click_link "Identifying Information" # expand field group

      # wait untill all elements are visiable
      wait_for(2)

      fill_in_title asset_resource_attributes[:title]                # see AssetResourceFormHelpers#fill_in_title
      fill_in_description asset_resource_attributes[:description]    # see AssetResourceFormHelpers#fill_in_description

      # validated metadata without errors
      page.find("#required-metadata")[:class].include?("complete")

      within('.asset_resource_asset_resource_types') do
        find('button.multiselect').click
        find('label.checkbox',text:asset_resource_attributes[:asset_resource_type]).click
      end

      click_link "Relationships" # define adminset relation
      find("#asset_resource_admin_set_id option[value='#{admin_set_id}']").select_option

      click_on('Save')

      visit '/'
      find("#search-submit-header").click

      # expect asset_resources is showing up
      expect(page).to have_content asset_resource_attributes[:title]

      # open asset_resource with detail show
      click_on(asset_resource_attributes[:title])

      expect(page).to have_content asset_resource_attributes[:asset_resource_type]
    end
  end
end
