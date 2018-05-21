require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Create and Validate Physical Instantiation', js: true do
  context 'Create adminset, create physical instantiation' do
    let(:admin_user) { create :admin_user }
    let!(:user_with_role) { create :user, role_names: ['user'] }
    let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
    let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
    let!(:workflow) { Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template) }

    let(:input_date_format) { '%m/%d/%Y' }
    let(:output_date_format) { '%F' }

    let(:physical_instantiation_attributes) do
      {
          title: "My Test Physical Instantiation",
          media_type: "Moving Image",
          format: 'DVD',
          location: 'Test Location',
          digitization_date: rand_date_time,
          date: rand_date_time,
          rights_summary: 'My Test Rights summary',
          rights_link: 'http://somerightslink.com/testlink',
          local_instantiation_identifer: 'localId1234',
          tracks: '2',
          holding_organization: 'WGBH',
          channel_configuration: 'Configured!',
          alternative_modes: 'This mode is so alternative'
      }
    end

    scenario 'Create and Validate Physical Instantiation, Search Physical Instantiation' do
      Sipity::WorkflowAction.create!(name: 'submit', workflow: workflow)
      Hyrax::PermissionTemplateAccess.create!(
          permission_template_id: permission_template.id,
          agent_type: 'group',
          agent_id: 'user',
          access: 'deposit'
      )

      # Login role user to create physical instantiation
      login_as(user_with_role)

      # create physical instantiation
      visit '/'
      click_link "Share Your Work"
      choose "payload_concern", option: "PhysicalInstantiation"
      click_button "Create work"
      expect(page).to have_content "Add New Physical Instantiation", wait: 20
      click_link "Files" # switch tab

      click_link "Descriptions" # switch tab

      click_link "Identifying Information" # expand field group
      wait_for(2) # wait untill all elements are visiable

      fill_in('Title', with: physical_instantiation_attributes[:title])

      # Select Format
      select = page.find('select#physical_instantiation_format')
      select.select physical_instantiation_attributes[:format]

      # Select Holding Organization
      select = page.find('select#physical_instantiation_holding_organization')
      select.select physical_instantiation_attributes[:holding_organization]

      # Select Media Type
      select = page.find('select#physical_instantiation_media_type')
      select.select physical_instantiation_attributes[:media_type]

      fill_in('Location', with: physical_instantiation_attributes[:location])

      # Expect the required metadata indicator to indicate 'complete'
      expect(page.find("#required-metadata")[:class]).to include "complete"

      fill_in('Date', with: physical_instantiation_attributes[:date].strftime(input_date_format))
      fill_in('Local instantiation identifer', with: physical_instantiation_attributes[:local_instantiation_identifer])

      click_link "Technical Info" # expand field group
      wait_for(2) # wait untill all elements are visiable


      fill_in('Tracks', with: physical_instantiation_attributes[:tracks])
      fill_in('Channel configuration', with: physical_instantiation_attributes[:channel_configuration])
      fill_in('Alternative modes', with: physical_instantiation_attributes[:alternative_modes])

      click_link "Rights" # expand field group
      wait_for(2) # wait untill all elements are visiable

      fill_in('Rights summary', with: physical_instantiation_attributes[:rights_summary])


      click_link "Relationships" # define adminset relation
      find("#physical_instantiation_admin_set_id option[value='#{admin_set_id}']").select_option

      # set it public
      find('body').click
      choose('physical_instantiation_visibility_open')
      expect(page).to have_content('Please note, making something visible to the world (i.e. marking this as Public) may be viewed as publishing which could impact your ability to')
      click_on('Save')

      wait_for(10) { PhysicalInstantiation.where(title: physical_instantiation_attributes[:title]).first }

      visit '/'
      find("#search-submit-header").click

      # expect physical instantiation is showing up
      expect(page).to have_content physical_instantiation_attributes[:title]
      expect(page).to have_content physical_instantiation_attributes[:date].strftime(output_date_format)


      # open physical instantiation with detail show
      click_on(physical_instantiation_attributes[:title])
      expect(page).to have_content physical_instantiation_attributes[:title]
      expect(page).to have_content physical_instantiation_attributes[:media_type]
      expect(page).to have_content physical_instantiation_attributes[:format]
      expect(page).to have_content physical_instantiation_attributes[:location]
      expect(page).to have_content physical_instantiation_attributes[:date].strftime(output_date_format)
      expect(page).to have_content physical_instantiation_attributes[:rights_summary]
      expect(page).to have_content physical_instantiation_attributes[:local_instantiation_identifer]
      expect(page).to have_content physical_instantiation_attributes[:tracks]
      expect(page).to have_content physical_instantiation_attributes[:channel_configuration]
      expect(page).to have_content physical_instantiation_attributes[:alternative_modes]
      expect(page).to have_content physical_instantiation_attributes[:holding_organization]
      expect(page).to have_current_path(guid_regex)
    end
  end
end

