require 'rails_helper'

# This is really a test of work done in the AssetActor
# Actor classes are very hard to test due to attempting to mock the entire environment,
# so this indirectly and imperfectly tests our saving expections
RSpec.feature 'Update AdminData', js: true, asset_form_helpers: true, clean: true do
  context 'Create adminset, create asset' do
    let(:admin_user) { create :admin_user }
    let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
    let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
    let!(:workflow) { Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template) }
    let!(:admindata) { create(:admin_data, :empty)}
    let!(:asset) { FactoryBot.create(:asset, with_admin_data: admindata.gid) }
    let(:admin_data_string_attributes) {
      {
        "Outside url" => "http://www.anotheroutsideurl.com/",
        "Licensing info" => "License expired",
        "Canonical meta tag" => "http://www.canonical.edu/",
        "Playlist group" => "group",
        "Playlist order" => "1",
        "Special collection" => "New Collection",
        "Special collection category" => "Weird",
        "Sony's Ci ID" => "1a2b3c4d5e"
      }
    }
    let(:admin_data_select_attributes) {
      {
        "asset_level_of_user_access" => "Private",
        "asset_minimally_cataloged" => "No",
        "asset_transcript_status" => "Correct",
        "asset_organization" => "BirdNote"
      }
    }

    scenario 'Update AdminData on Asset' do
      Sipity::WorkflowAction.create!(name: 'submit', workflow: workflow)
      Hyrax::PermissionTemplateAccess.create!(
        permission_template_id: permission_template.id,
        agent_type: 'group',
        agent_id: 'ingester',
        access: 'deposit'
      )

      login_as(admin_user)

      visit edit_hyrax_asset_path(asset)

      click_on("AAPB Admin Data")

      # Fill in new AdminData string attribute values
      admin_data_string_attributes.each do |attribute, val|
        fill_in(attribute, with: val)
      end

      # Fill in new AdminData select attribute values
      admin_data_select_attributes.each do |attribute, val|
        find("select#" + attribute).find("option[value=" + val).select_option
      end

      click_on("Save changes")

      visit hyrax_asset_path(asset)

      # Expand the hidden section
      click_on("Aapb Admin")

      # Test for new AdminData string attribute values
      admin_data_string_attributes.merge(admin_data_select_attributes).each do |attribute, val|
        expect(page).to have_content(val)
      end

      visit edit_hyrax_asset_path(asset)

      # We want to make sure that values are getting removed via the AssetActor
      # Fill in empty AdminData string attribute values
      admin_data_string_attributes.each do |attribute, val|
        fill_in(attribute, with: "")
      end

      # Fill in empty AdminData select attribute values
      admin_data_select_attributes.each do |attribute, val|
        find("select#" + attribute).find("option[value='']").select_option
      end

      click_on("Save changes")
      visit hyrax_asset_path(asset)

      # Test for absence of AdminData section
      expect(page).not_to have_content("Aapb Admin")
    end
  end
end
