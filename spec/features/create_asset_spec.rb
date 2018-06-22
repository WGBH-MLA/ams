require 'rails_helper'
require_relative '../../app/services/title_and_description_types_service'
require_relative '../../app/services/date_types_service'
include Warden::Test::Helpers

RSpec.feature 'Create and Validate Asset', js: true, asset_form_helpers: true, clean:true do
  context 'Create adminset, create asset' do
    let(:admin_user) { create :admin_user }
    let!(:user_with_role) { create :user, role_names: ['user'] }
    let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
    let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
    let!(:workflow) { Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template) }

    let(:input_date_format) { '%m/%d/%Y' }
    let(:output_date_format) { '%F' }

    let(:asset_attributes) do
      { title: "My Test Title", description: "My Test Description", spatial_coverage: 'My Test Spatial coverage',
        temporal_coverage: 'My Test Temporal coverage', audience_level: 'My Test Audience level',
        audience_rating: 'My Test Audience rating', annotation: 'My Test Annotation', rights_summary: 'My Test Rights summary' }
    end

    # Use contolled vocab to retrieve all title types.
    let(:title_and_description_types) { TitleAndDescriptionTypesService.all_terms }

    # Make an array of [title, title_type] pairs.
    # Ensure there are 2 titles for every title type.
    let(:titles_with_types) do
      (title_and_description_types * 2).each_with_index.map do |title_type, i|
        test_title = "Test #{title_type} Title #{i+1}".gsub(/\s+/, ' ')
        [test_title, title_type]
      end
    end


    # Make an array of [description, description_type] pairs.
    # Ensure there are 2 descriptions for every description type.
    let(:descriptions_with_types) do
      (title_and_description_types * 2).each_with_index.map do |description_type, i|
        test_description = "Test #{description_type} Description #{i+1}".gsub(/\s+/, ' ')
        [test_description, description_type]
      end
    end

    # array of main titles, i.e. all titles without a type
    let(:main_titles) do
      titles_with_types.select do |_title, title_type|
        title_type.blank?
      end.map do |title, _title_type|
        title
      end
    end

    # Specify a main description.
    let(:main_description) { descriptions_with_types.first.first }

    # Make an array of [date, date_type] pairs.
    # Ensure there are 2 date for every date type.
    let(:dates_with_types) do
      (DateTypesService.all_terms * 2).each_with_index.map { |date_type, i| [rand_date_time.strftime(output_date_format), date_type] }
    end

    let(:contribution_attributes) {FactoryBot.attributes_for(:contribution)}

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
      visit new_hyrax_asset_path
      expect(page).to have_content "Add New Asset"

      click_link "Files" # switch tab
      expect(page).to have_content "Add files"
      expect(page).to have_content "Add folder"

      # validate metadata with errors
      page.find("#required-metadata")[:class].include?("incomplete")

      click_link "Descriptions" # switch tab

      click_link "Identifying Information" # expand field group
      wait_for(2) # wait untill all elements are visiable

      fill_in_titles_with_types(titles_with_types)                                # see AssetFormHelper#fill_in_titles_with_types
      fill_in_descriptions_with_types(descriptions_with_types)                    # see AssetFormHelper#fill_in_descriptions_with_types

      # validated metadata without errors
      page.find("#required-metadata")[:class].include?("complete")

      # wait untill all elements are visiable
      wait_for(2)

      click_link "Subject Information" # expand field group

      fill_in('Spatial coverage', with: asset_attributes[:spatial_coverage])
      fill_in('Temporal coverage', with: asset_attributes[:temporal_coverage])
      fill_in('Audience level', with: asset_attributes[:audience_level])
      fill_in('Audience rating', with: asset_attributes[:audience_rating])
      fill_in('Annotation', with: asset_attributes[:annotation])

      click_link "Rights" # expand field group
      wait_for(2) # wait untill all elements are visiable

      fill_in('Rights summary', with: asset_attributes[:rights_summary])


      click_link "Credits" # expand field group
      wait_for(2) # wait untill all elements are visiable

      select(contribution_attributes[:contributor_role].first, :from => "asset_child_contributors_0_role")

      fill_in('asset_child_contributors_0_contributor', with: contribution_attributes[:contributor].first)
      fill_in('asset_child_contributors_0_portrayal', with: contribution_attributes[:portrayal].first)

      click_link "Relationships" # define adminset relation
      find("#asset_admin_set_id option[value='#{admin_set_id}']").select_option


      # set it public
      find('body').click
      choose('asset_visibility_open')
      expect(page).to have_content('Please note, making something visible to the world (i.e. marking this as Public) may be viewed as publishing which could impact your ability to')

      click_on('Save')

      visit '/'
      find("#search-submit-header").click

      # Filter resources types
      click_on('Type')
      click_on('Asset')


      # Expect metadata for Asset to be displayed on the search results page.
      main_titles.each do |main_title|
        expect(page).to have_content main_title
      end

      # open asset with detail show
      click_on main_titles.first
      expect(page).to have_content asset_attributes[:spatial_coverage]
      expect(page).to have_content asset_attributes[:temporal_coverage]
      expect(page).to have_content asset_attributes[:audience_level]
      expect(page).to have_content asset_attributes[:audience_rating]
      expect(page).to have_content asset_attributes[:annotation]
      expect(page).to have_content asset_attributes[:rights_summary]
      expect(page).to have_current_path(guid_regex)

      expect(page).to have_link(href: /contributions/)
      #Clicking contribution link from members table
      within('.thumbnail') {find('a[href*="contribution"]').click }

      expect(page).to have_content contribution_attributes[:contributor].first
      expect(page).to have_content contribution_attributes[:portrayal].first
      expect(page).to have_content contribution_attributes[:contributor_role].first
      expect(page).to have_current_path(guid_regex)
    end
  end
end
