require 'rails_helper'
require_relative '../../app/services/title_and_description_types_service'
include Warden::Test::Helpers

RSpec.feature 'Create and Validate Asset', js: true, asset_form_helpers: true do
  context 'Create adminset, create asset' do
    let(:admin_user) { create :admin_user }
    let!(:user_with_role) { create :user_with_role, role_name: 'user' }
    let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
    let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(admin_set_id: admin_set_id) }
    let!(:workflow) { Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template) }

    let(:input_date_format) { '%m/%d/%Y' }
    let(:output_date_format) { '%F' }

    let(:asset_attributes) do
      { description: "My Test Description", broadcast: rand_date_time, created: rand_date_time, date: rand_date_time, copyright_date: rand_date_time,
        episode_number: 'EP#11', spatial_coverage: 'My Test Spatial coverage', temporal_coverage: 'My Test Temporal coverage', audience_level: 'My Test Audience level',
        audience_rating: 'My Test Audience rating', annotation: 'My Test Annotation', rights_summary: 'My Test Rights summary', rights_link: 'http://somerightslink.com/testlink', local_identifier: 'localID1234', pbs_nola_code: 'nolaCode1234', eidr_id: 'http://someeidrlink.com/testlink', topics: ['Biography', 'Women'], subject: 'Danger' }
    end

    # Use contolled vocab to retrieve all title types.
    let(:title_and_description_types) { TitleAndDescriptionTypesService.all_terms }

    # Make an array of [title, title_type] pairs.
    # Ensure there are 2 titles for every title type.
    let(:titles_with_types) do
      (title_and_description_types * 2).each_with_index.map { |title_type, i| ["Test #{title_type} Title #{i+1}", title_type] }
    end

    # Specify a main title.
    let(:main_title) { titles_with_types.first.first }

    # Make an array of [description, description_type] pairs.
    # Ensure there are 2 descriptions for every description type.
    let(:descriptions_with_types) do
      (title_and_description_types * 2).each_with_index.map { |description_type, i| ["Test #{description_type} Description #{i+1}", description_type] }
    end

    # Specify a main description.
    let(:main_description) { descriptions_with_types.first.first }

    scenario 'Create and Validate Asset, Search asset' do
      Sipity::WorkflowAction.create!(name: 'submit', workflow: workflow)
      Hyrax::PermissionTemplateAccess.create!(
        permission_template_id: permission_template.id,
        agent_type: 'group',
        agent_id: 'user',
        access: 'deposit'
      )
      # Login role user to create asset
      login_as(user_with_role)

      # create asset
      visit '/'
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
      fill_in_titles_with_types(titles_with_types)              # see AssetFormHelper#fill_in_titles_with_types
      fill_in_descriptions_with_types(descriptions_with_types)   # see AssetFormHelper#fill_in_descriptions_with_types


      # validated metadata without errors
      page.find("#required-metadata")[:class].include?("complete")

      click_link "Additional fields" # additional metadata

      fill_in('Subject', with: asset_attributes[:subject])
      fill_in('Broadcast', with: asset_attributes[:broadcast].strftime(input_date_format))
      fill_in('Created', with: asset_attributes[:created].strftime(input_date_format))
      fill_in('Date', with: asset_attributes[:date].strftime(input_date_format))
      fill_in('Copyright date', with: asset_attributes[:copyright_date].strftime(input_date_format))
      fill_in('Episode number', with: asset_attributes[:episode_number])
      fill_in('Spatial coverage', with: asset_attributes[:spatial_coverage])
      fill_in('Temporal coverage', with: asset_attributes[:temporal_coverage])
      fill_in('Audience level', with: asset_attributes[:audience_level])
      fill_in('Audience rating', with: asset_attributes[:audience_rating])
      fill_in('Annotation', with: asset_attributes[:annotation])
      fill_in('Rights summary', with: asset_attributes[:rights_summary])
      fill_in('Rights link', with: asset_attributes[:rights_link])
      fill_in('Local identifier', with: asset_attributes[:local_identifier])
      fill_in('Pbs nola code', with: asset_attributes[:pbs_nola_code])
      fill_in('Eidr', with: asset_attributes[:eidr_id])

      asset_attributes[:topics].each do |topic|
        page.select topic, from: 'Topics'
      end

      click_link "Relationships" # define adminset relation
      find("#asset_admin_set_id option[value='#{admin_set_id}']").select_option

      # set it public
      find('body').click
      choose('asset_visibility_open')
      expect(page).to have_content('Please note, making something visible to the world (i.e. marking this as Public) may be viewed as publishing which could impact your ability to')

      click_on('Save')

      visit '/'
      find("#search-submit-header").click

      # expect assets is showing up
      expect(page).to have_content main_title
      expect(page).to have_content main_description
      expect(page).to have_content asset_attributes[:broadcast].strftime(output_date_format)
      expect(page).to have_content asset_attributes[:created].strftime(output_date_format)
      expect(page).to have_content asset_attributes[:copyright_date].strftime(output_date_format)
      expect(page).to have_content asset_attributes[:episode_number]

      # open asset with detail show
      click_on main_title
      expect(page).to have_content asset_attributes[:broadcast].strftime(output_date_format)
      expect(page).to have_content asset_attributes[:created].strftime(output_date_format)
      expect(page).to have_content asset_attributes[:date].strftime(output_date_format)
      expect(page).to have_content asset_attributes[:copyright_date].strftime(output_date_format)
      expect(page).to have_content asset_attributes[:episode_number]
      expect(page).to have_content asset_attributes[:spatial_coverage]
      expect(page).to have_content asset_attributes[:temporal_coverage]
      expect(page).to have_content asset_attributes[:audience_level]
      expect(page).to have_content asset_attributes[:audience_rating]
      expect(page).to have_content asset_attributes[:annotation]
      expect(page).to have_content asset_attributes[:rights_summary]
      expect(page).to have_content asset_attributes[:rights_link]
      expect(page).to have_content asset_attributes[:local_identifier]
      expect(page).to have_content asset_attributes[:pbs_nola_code]
      expect(page).to have_content asset_attributes[:eidr_id]

      asset_attributes[:topics].each do |topic|
        expect(page).to have_content topic
      end
      expect(page).to have_current_path(guid_regex)
    end
  end
end
