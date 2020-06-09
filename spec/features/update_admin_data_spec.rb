require 'rails_helper'
require_relative '../../app/services/title_types_service'
require_relative '../../app/services/description_types_service'
require_relative '../../app/services/date_types_service'

RSpec.feature 'Create and Validate Asset', js: true, asset_form_helpers: true, clean: true do
  context 'Create adminset, create asset' do
    let(:admin_user) { create :admin_user }
    let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
    let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
    let!(:workflow) { Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template) }
    let!(:asset) { FactoryBot.create(:asset, admin_data: FactoryBot.create(:admin_data)) }

    scenario 'Update AdminData on Asset' do
      Sipity::WorkflowAction.create!(name: 'submit', workflow: workflow)
      Hyrax::PermissionTemplateAccess.create!(
        permission_template_id: permission_template.id,
        agent_type: 'group',
        agent_id: 'ingester',
        access: 'deposit'
      )

      login_as(admin_user)

      visit hyrax_asset_path(asset)
      click_on("Aapb Admin")

      expect(page).to have_content "Outside url"
      expect(page).to have_content "http://www.someoutsideurl.com/"

      visit edit_hyrax_asset_path(asset)
      fill_in("Outside url", with: "")
      click_on("Save changes")

      visit hyrax_asset_path(asset)
      click_on("Aapb Admin")

      expect(page).not_to have_content "Outside url"
      expect(page).not_to have_content "http://www.someoutsideurl.com/"
    end
  end
end
