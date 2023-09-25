require 'rails_helper'

# This is really a test of work done in the AssetActor
# Actor classes are very hard to test due to attempting to mock the entire environment,
# so this indirectly and imperfectly tests our saving expections
RSpec.feature 'Update AdminData', asset_form_helpers: true, clean: true do
  context 'Create adminset, create asset' do
    let(:admin_user) { create :admin_user }
    let(:admin_set_id) { Hyrax::AdminSetCreateService.find_or_create_default_admin_set.id.to_s }
    let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
    let!(:workflow) { Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template) }
    let!(:admindata) { create(:admin_data, :empty)}
    let!(:asset) { FactoryBot.create(:asset, with_admin_data: admindata.gid) }
    let(:fake_sonyci_id) { rand(999999) }
    let(:fake_sonyci_records) {
      { fake_sonyci_id: { 'id' => fake_sonyci_id, 'name' => 'foo' } }
    }
    let(:admin_data_string_attributes) {
      {
        "Sony's Ci ID" => fake_sonyci_id
      }
    }

    before do
      # It's not apparent, but this is required to avoid errors.
      # When the Sony Ci ID input is rendered, AdminData#sonyci_records is
      # called. which calls SonyCiApi::Client#asset to fetch the records.
      # NOTE: confusingly, the Sony Ci API refers to the records as 'assets'.
      allow_any_instance_of(SonyCiApi::Client).to receive(:asset).with(fake_sonyci_id.to_s).and_return(fake_sonyci_records)
    end

    scenario 'Update AdminData on Asset' do
      skip 'TODO fix feature specs'
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
