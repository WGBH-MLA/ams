require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Create and Validate Series', js: true do
  context 'Create adminset, create series' do
    let(:admin_user) { create :admin_user }
    let!(:user_with_role) { create :user_with_role, role_name: 'user' }
    let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
    let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(admin_set_id: admin_set_id) }
    let!(:workflow) { Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template) }

    let(:series_attributes) do
      {
        title: "My Test Series",
        description: "A test Series for testing!",
        audience_level: 'My Test Audience level',
        audience_rating: 'My Test Audience rating',
        annotation: 'My Test Annotation',
        rights_summary: 'My Test Rights summary',
        rights_link: 'http://somerightslink.com/testlink'
      }
    end

    scenario 'Create and Validate Series, Search series' do
      Sipity::WorkflowAction.create!(name: 'submit', workflow: workflow)
      Hyrax::PermissionTemplateAccess.create!(
        permission_template_id: permission_template.id,
        agent_type: 'group',
        agent_id: 'user',
        access: 'deposit'
      )
      # Login role user to create series
      login_as(user_with_role)

      # create series
      visit '/'
      click_link "Share Your Work"
      choose "payload_concern", option: "Series"
      click_button "Create work"
      expect(page).to have_content "Add New Series", wait: 20
      click_link "Files" # switch tab
      expect(page).to have_content "Add files"
      expect(page).to have_content "Add folder"

      # Expect the required metadata indicator to indicate 'incomplete'
      expect(page.find("#required-metadata")[:class]).to include "incomplete"

      click_link "Descriptions" # switch tab
      fill_in('Title', with: series_attributes[:title])
      fill_in('Description', with: series_attributes[:description])

      # Expect the required metadata indicator to indicate 'complete'
      expect(page.find("#required-metadata")[:class]).to include "complete"

      click_link "Additional fields" # additional metadata

      fill_in('Audience level', with: series_attributes[:audience_level])
      fill_in('Audience rating', with: series_attributes[:audience_rating])
      fill_in('Annotation', with: series_attributes[:annotation])
      fill_in('Rights summary', with: series_attributes[:rights_summary])
      fill_in('Rights link', with: series_attributes[:rights_link])

      click_link "Relationships" # define adminset relation
      find("#series_admin_set_id option[value='#{admin_set_id}']").select_option

      # set it public
      find('body').click
      choose('series_visibility_open')
      expect(page).to have_content('Please note, making something visible to the world (i.e. marking this as Public) may be viewed as publishing which could impact your ability to')
      click_on('Save')

      wait_for(10) { Series.where(title: series_attributes[:title]).first }

      visit '/'
      find("#search-submit-header").click

      # expect series is showing up
      expect(page).to have_content series_attributes[:title]
      expect(page).to have_content series_attributes[:description]

      # open series with detail show
      click_on(series_attributes[:title])
      expect(page).to have_content series_attributes[:title]
      expect(page).to have_content series_attributes[:description]
      expect(page).to have_content series_attributes[:audience_level]
      expect(page).to have_content series_attributes[:audience_rating]
      expect(page).to have_content series_attributes[:annotation]
      expect(page).to have_content series_attributes[:rights_summary]
      expect(page).to have_content series_attributes[:rights_link]
      exit
    end
  end
end

