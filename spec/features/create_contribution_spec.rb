# Generated via
#  `rails generate hyrax:work Contribution`
require 'rails_helper'
include Warden::Test::Helpers

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.feature 'Create a Contriubtion', js: true do
  context 'a logged in user' do
    let(:admin_user) { create :admin_user }
    let!(:user_with_role) { create :user_with_role, role_name: 'user' }
    let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }

    let!(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
    let!(:workflow) { Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template) }

    let(:input_date_format) { '%m/%d/%Y' }
    let(:output_date_format) { '%F' }

    let(:contribution_attributes) do
      {
          title: "My Test Contribution",
          contributor: "Test Contributor",
          contributor_role: 'Actor',
          portrayal: 'portrayal'
      }
    end

    before do
      Sipity::WorkflowAction.create!(name: 'submit', workflow: workflow)
      Hyrax::PermissionTemplateAccess.create!(
          permission_template_id: permission_template.id,
          agent_type: 'group',
          agent_id: 'user',
          access: 'deposit'
      )
      # Login role user to create DigitalInstantiation
      login_as(user_with_role)
    end

    scenario do
      visit '/dashboard'
      click_link "Works"
      click_link "Add new work"

      # If you generate more than one work uncomment these lines
      choose "payload_concern", option: "Contribution"
      click_button "Create work"

      expect(page).to have_content "Add New Contribution"
      fill_in('Title', with: contribution_attributes[:title])

      click_link "Additional fields" # additional metadata

      fill_in('Contributor', with: contribution_attributes[:contributor])
      # Select role
      select = page.find('select#contribution_contributor_role')
      select.select contribution_attributes[:contributor_role]
      fill_in('Portrayal', with: contribution_attributes[:portrayal])

      # set it public
      find('body').click
      choose('contribution_visibility_open')
      expect(page).to have_content('Please note, making something visible to the world (i.e. marking this as Public) may be viewed as publishing which could impact your ability to')
      click_on('Save')

      wait_for(10) { Contribution.where(title: contribution_attributes[:title]).first }

      visit '/'
      find("#search-submit-header").click

      # expect digital instantiation is showing up
      expect(page).to have_content contribution_attributes[:title]

      click_on(contribution_attributes[:title])

      expect(page).to have_content contribution_attributes[:title]
      expect(page).to have_content contribution_attributes[:contributor]
      expect(page).to have_content contribution_attributes[:contributor_role]
      expect(page).to have_content contribution_attributes[:portrayal]

    end
  end
end
