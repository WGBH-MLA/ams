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
        "Sony's Ci ID" => "1a2b3c4d5e"
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

      click_on("Save changes")

      visit hyrax_asset_path(asset)

      # Expand the hidden section
      click_on("Aapb Admin")

      # Test for new AdminData string attribute values
      admin_data_string_attributes.each do |attribute, val|
        expect(page).to have_content(val)
      end

      visit edit_hyrax_asset_path(asset)

      # We want to make sure that values are getting removed via the AssetActor
      # Fill in empty AdminData string attribute values
      admin_data_string_attributes.each do |attribute, val|
        fill_in(attribute, with: "")
      end

      click_on("Save changes")
      visit hyrax_asset_path(asset)

      # Test for absence of AdminData section
      expect(page).not_to have_content("Aapb Admin")
    end
  end
end
