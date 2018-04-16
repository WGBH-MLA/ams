# Generated via
#  `rails generate hyrax:work EssenceTrack`
require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Create and Validate Essence Track', js: true do
  context 'Create adminset, create EssenceTrack' do
    let(:admin_user) { create :admin_user }
    let!(:user_with_role) { create :user_with_role, role_name: 'user' }
    let!(:admin_set) { create :admin_set, title: ["Test Admin Set"] }

    let!(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(admin_set_id: admin_set.id) }
    let!(:workflow) { Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template) }

    let(:input_date_format) { '%m/%d/%Y' }
    let(:output_date_format) { '%F' }

    let(:essence_track_attributes) do
      {
          title: "My Test Essence Track",
          media_type: "Moving Image",
          format: 'DVD',
          location: 'Test Location',
          date: rand_date_time,
          rights_summary: 'My Test Rights summary',
          rights_link: 'http://somerightslink.com/testlink'
      }
    end

    scenario 'Create and Validate Essence Track, Search Essence Track' do
      Sipity::WorkflowAction.create!(name: 'submit', workflow: workflow)
      Hyrax::PermissionTemplateAccess.create!(
          permission_template_id: permission_template.id,
          agent_type: 'group',
          agent_id: 'user',
          access: 'deposit'
      )
      # Login role user to create Essence Track
      login_as(user_with_role)

      # create essence track
      visit '/'
      click_link "Share Your Work"
      choose "payload_concern", option: "EssenceTrack"
      click_button "Create work"
      expect(page).to have_content "Add New Essence Track", wait: 20
      click_link "Files" # switch tab

      click_link "Descriptions" # switch tab
      fill_in('Title', with: essence_track_attributes[:title])

      # Select Format
      select = page.find('select#essence_track_format')
      select.select essence_track_attributes[:format]

      # Select Media Type
      select = page.find('select#essence_track_media_type')
      select.select essence_track_attributes[:media_type]

      fill_in('Location', with: essence_track_attributes[:location])

      # Expect the required metadata indicator to indicate 'complete'
      expect(page.find("#required-metadata")[:class]).to include "complete"

      click_link "Additional fields" # additional metadata

      fill_in('Date', with: essence_track_attributes[:date].strftime(input_date_format))
      fill_in('Rights summary', with: essence_track_attributes[:rights_summary])
      fill_in('Rights link', with: essence_track_attributes[:rights_link])

      click_link "Relationships" # define adminset relation
      find("#essence_track_admin_set_id option[value='#{admin_set.id}']").select_option

      # set it public
      find('body').click
      choose('essence_track_visibility_open')
      expect(page).to have_content('Please note, making something visible to the world (i.e. marking this as Public) may be viewed as publishing which could impact your ability to')
      click_on('Save')

      wait_for(10) { EssenceTrack.where(title: essence_track_attributes[:title]).first }

      visit '/'
      find("#search-submit-header").click

      # expect essence track is showing up
      expect(page).to have_content essence_track_attributes[:title]
      expect(page).to have_content essence_track_attributes[:date].strftime(output_date_format)

      # open essence track with detail show
      click_on(essence_track_attributes[:title])
      expect(page).to have_content essence_track_attributes[:title]
      expect(page).to have_content essence_track_attributes[:media_type]
      expect(page).to have_content essence_track_attributes[:format]
      expect(page).to have_content essence_track_attributes[:location]
      expect(page).to have_content essence_track_attributes[:date].strftime(output_date_format)
      expect(page).to have_content essence_track_attributes[:rights_summary]
      expect(page).to have_content essence_track_attributes[:rights_link]
      exit
    end
  end
end
