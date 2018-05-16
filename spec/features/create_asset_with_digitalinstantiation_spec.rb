require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Create and Validate Asset,Digital Instantiation, EssenseTrack', js: true, asset_form_helpers: true,
              disable_animation:true do
  context 'Create adminset, create asset, import pbcore xml for digital instantiation and essensetrack' do
    let(:admin_user) { create :admin_user }
    let!(:user_with_role) { create :user_with_role, role_name: 'user' }
    let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
    let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
    let!(:workflow) { Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template) }

    let(:input_date_format) { '%m/%d/%Y' }
    let(:output_date_format) { '%F' }

    let(:asset_attributes) do
      { title: "My Test Title", description: "My Test Description",spatial_coverage: 'My Test Spatial coverage',
        temporal_coverage: 'My Test Temporal coverage', audience_level: 'My Test Audience level',
        audience_rating: 'My Test Audience rating', annotation: 'My Test Annotation', rights_summary: 'My Test Rights summary' }
    end

    let(:digital_instantiation_attributes) do
      {
        title: "My Test Digital Instantiation",
        media_type: "Moving Image",
        digital_format: 'video/mp4',
        location: 'Test Location',
        rights_summary: 'My Test Rights summary',
        pbcore_xml_doc: "#{Rails.root}/spec/fixtures/sample_instantiation_valid.xml"
      }
    end

    let(:pbcore_xml_doc) { PBCore::V2::InstantiationDocument.parse(File.read("#{Rails.root}/spec/fixtures/sample_instantiation_valid.xml")) }

    scenario 'Create and Validate Asset, Search asset' do
      Sipity::WorkflowAction.create!(name: 'submit', workflow: workflow)
      Hyrax::PermissionTemplateAccess.create!(
        permission_template_id: permission_template.id,
        agent_type: 'group',
        agent_id: 'user',
        access: 'manage'
      )
      # Login role user to create asset
      login_as(user_with_role)

      # create asset
      visit '/'

      disable_js_animation

      click_link "Share Your Work"
      choose "payload_concern", option: "Asset"
      click_button "Create work"

      expect(page).to have_content "Add New Asset"

      click_link "Files" # switch tab
      expect(page).to have_content "Add files"
      expect(page).to have_content "Add folder"

      # validate metadata with errors
      page.find("#required-metadata")[:class].include?("incomplete")

      click_link "Descriptions" # switch tab

      click_link "Identifying Information" # expand field group

      #wait untill all elements are visiable
      wait_for(2)

      fill_in_title asset_attributes[:title]                  # see AssetFormHelpers#fill_in_title
      fill_in_description asset_attributes[:description]      # see AssetFormHelpers#fill_in_description

      # validated metadata without errors
      page.find("#required-metadata")[:class].include?("complete")

      #wait untill all elements are visiable
      wait_for(2)

      click_link "Subject Information" # expand field group

      fill_in('Spatial coverage', with: asset_attributes[:spatial_coverage])
      fill_in('Temporal coverage', with: asset_attributes[:temporal_coverage])
      fill_in('Audience level', with: asset_attributes[:audience_level])
      fill_in('Audience rating', with: asset_attributes[:audience_rating])
      fill_in('Annotation', with: asset_attributes[:annotation])

      #wait untill all elements are visiable
      wait_for(2)

      click_link "Rights" # expand field group
      fill_in('Rights summary', with: asset_attributes[:rights_summary])

      click_link "Relationships" # define adminset relation
      find("#asset_admin_set_id option[value='#{admin_set_id}']").select_option

      # set it public
      find('body').click
      choose('asset_visibility_open')
      expect(page).to have_content('Please note, making something visible to the world (i.e. marking this as Public) may be viewed as publishing which could impact your ability to')

      click_on('Save')

      visit '/'
      find("#search-submit-header").click

      # Expect metadata for Asset to be displayed on the search results page.
      expect(page).to have_content asset_attributes[:title]

      # open asset with detail show
      click_on asset_attributes[:title]

      expect(page).to have_content asset_attributes[:spatial_coverage]
      expect(page).to have_content asset_attributes[:temporal_coverage]
      expect(page).to have_content asset_attributes[:audience_level]
      expect(page).to have_content asset_attributes[:audience_rating]
      expect(page).to have_content asset_attributes[:annotation]
      expect(page).to have_content asset_attributes[:rights_summary]
      expect(page).to have_current_path(guid_regex)

      click_on('Add Digital Instantiation')

      within 'form#new_digital_instantiation' do
        attach_file('Digital instantiation pbcore xml', File.absolute_path(digital_instantiation_attributes[:pbcore_xml_doc]))

        click_link "Technical Info" # expand technical info field group

        page.select digital_instantiation_attributes[:media_type], from: 'Media type'

        page.select digital_instantiation_attributes[:digital_format], from: 'Digital format'

        click_link "Identifying Information" # expand field group

        fill_in('Title', with: digital_instantiation_attributes[:title])

        fill_in('Location', with: digital_instantiation_attributes[:location])

        click_link "Rights" # expand field group

        fill_in('Rights summary', with: digital_instantiation_attributes[:rights_summary])
      end

      # set it public
      find('body').click
      choose('digital_instantiation_visibility_open')
      expect(page).to have_content('Please note, making something visible to the world (i.e. marking this as Public) may be viewed as publishing which could impact your ability to')
      click_on('Save')

      wait_for(10) { DigitalInstantiation.where(title: digital_instantiation_attributes[:title]).first }

      visit '/'
      find("#search-submit-header").click

      # expect digital instantiation is showing up
      expect(page).to have_content digital_instantiation_attributes[:title]

      # Filter resources types
      click_on('Type')
      click_on('Digital Instantiation')

      # open digital instantiation with detail show
      click_on(digital_instantiation_attributes[:title])
      expect(page).to have_content digital_instantiation_attributes[:title]
      expect(page).to have_content digital_instantiation_attributes[:location]
      expect(page).to have_content digital_instantiation_attributes[:rights_summary]
      expect(page).to have_content digital_instantiation_attributes[:media_type]
      expect(page).to have_content digital_instantiation_attributes[:digital_format]
      expect(page).to have_current_path(guid_regex)
    end
  end
end
