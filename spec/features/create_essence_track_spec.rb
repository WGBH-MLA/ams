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

    let(:essence_track_attributes) do
      {
          title: "My Test Essence Track",
          track_type: "My Test Essence Track Type",
          standard: "Test Stadndard",
          track_id: "TEST12",
          encoding: 'TEST',
          data_rate: '6400',
          frame_rate: '1200',
          playback_inch_per_sec: '12',
          playback_frame_per_sec: '20',
          sample_rate: '5000',
          bit_depth: '2',
          frame_width: '1100',
          frame_height: '12',
          time_start: '0:11:00',
          duration: '220',
          language: 'English',
          annotation: 'Test Annotation'

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
      fill_in('Track Type', with: essence_track_attributes[:track_type])
      fill_in('Track ID', with: essence_track_attributes[:track_id])



      # Expect the required metadata indicator to indicate 'complete'
      expect(page.find("#required-metadata")[:class]).to include "complete"

      click_link "Additional fields" # additional metadata

      # Select asset type
      select = page.find('select#essence_track_language')
      select.select essence_track_attributes[:language]


      fill_in('Standard', with: essence_track_attributes[:standard])
      fill_in('Encoding', with: essence_track_attributes[:encoding])
      fill_in('Data Rate (in bytes/second)', with: essence_track_attributes[:data_rate])
      fill_in('Frame Rate (in frames/second)', with: essence_track_attributes[:frame_rate])
      fill_in('Playback Speed (inches/second)', with: essence_track_attributes[:playback_inch_per_sec])
      fill_in('Playback Speed (frames/second)', with: essence_track_attributes[:playback_frame_per_sec])
      fill_in('Sampling Rate (in kHz)', with: essence_track_attributes[:sample_rate])
      fill_in('Bit Depth', with: essence_track_attributes[:bit_depth])
      fill_in('Frame Width (in pixels)', with: essence_track_attributes[:frame_width])
      fill_in('Frame Height (in pixels)', with: essence_track_attributes[:frame_height])
      fill_in('Time start', with: essence_track_attributes[:time_start])
      fill_in('Duration', with: essence_track_attributes[:duration])
      fill_in('Annotation', with: essence_track_attributes[:annotation])


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


      # open essence track with detail show
      click_on(essence_track_attributes[:title])
      expect(page).to have_content essence_track_attributes[:title]
      expect(page).to have_content essence_track_attributes[:track_type]
      expect(page).to have_content essence_track_attributes[:track_id]
      expect(page).to have_content essence_track_attributes[:encoding]
      expect(page).to have_content essence_track_attributes[:data_rate]
      expect(page).to have_content essence_track_attributes[:frame_rate]
      expect(page).to have_content essence_track_attributes[:playback_inch_per_sec]
      expect(page).to have_content essence_track_attributes[:playback_frame_per_sec]
      expect(page).to have_content essence_track_attributes[:sample_rate]
      expect(page).to have_content essence_track_attributes[:frame_width]
      expect(page).to have_content essence_track_attributes[:frame_height]
      expect(page).to have_content essence_track_attributes[:time_start]
      expect(page).to have_content essence_track_attributes[:duration]
      expect(page).to have_content essence_track_attributes[:annotation]
      expect(page).to have_content essence_track_attributes[:language]
    end
  end
end
