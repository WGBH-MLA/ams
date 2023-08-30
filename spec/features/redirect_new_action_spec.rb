require 'rails_helper'

RSpec.feature 'Redirect controller#new actions', js: true do
  context 'a logged in User' do
    let(:admin_user) { create :admin_user }
    let!(:user_with_role) { create :user, role_names: ['ingester'] }
    let(:admin_set_id) { Hyrax::AdminSetCreateService.find_or_create_default_admin_set.id.to_s }

    let!(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
    let!(:workflow) { Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template) }

    before do
      Sipity::WorkflowAction.create!(name: 'submit', workflow: workflow)
      Hyrax::PermissionTemplateAccess.create!(
          permission_template_id: permission_template.id,
          agent_type: 'user',
          agent_id: user_with_role.email,
          access: 'deposit'
      )
      # Login role user to create DigitalInstantiation
      login_as(user_with_role)
    end

    scenario 'tries to access digital_instantiations#new' do
      visit '/concern/digital_instantiations/new'
      expect(current_path).to eq(hyrax.my_works_path)
      expect(page).to have_content "Digital Instantiation must be created from an Asset."
    end

    scenario 'tries to access physical_instantiations#new' do
      visit '/concern/physical_instantiations/new'
      expect(current_path).to eq(hyrax.my_works_path)
      expect(page).to have_content "Physical Instantiation must be created from an Asset."
    end

    scenario 'tries to access essence_tracks#new' do
      visit '/concern/essence_tracks/new'
      expect(current_path).to eq(hyrax.my_works_path)
      expect(page).to have_content "Essence Track must be created from an Asset."
    end

    scenario 'tries to access contributions#new' do
      visit '/concern/contributions/new'
      expect(current_path).to eq(hyrax.my_works_path)
      expect(page).to have_content "Contribution must be created from an Asset."
    end

    scenario 'tries to access assets#new' do
      visit 'concern/assets/new'
      expect(current_path).to eq(new_hyrax_asset_path)
    end
  end
end
