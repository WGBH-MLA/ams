require 'rails_helper'

RSpec.feature 'Create and Validate Asset,Digital Instantiation, EssenseTrack', js: true, asset_form_helpers: true,
              disable_animation:true, expand_fieldgroup: true  do
  context 'Create adminset, create asset, import pbcore xml for digital instantiation and essensetrack' do
    let(:admin_user) { create :admin_user }
    let!(:user_with_role) { create :user, role_names: ['user'] }
    # let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
    let(:admin_set_id) { create(:admin_set).id }
    let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
    let!(:workflow) { Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template) }

    let(:input_date_format) { '%m/%d/%Y' }
    let(:output_date_format) { '%F' }

    let(:asset_attributes) do
      { title: "My Test Title"+ get_random_string, description: "My Test Description",spatial_coverage: 'My Test Spatial coverage',
        temporal_coverage: 'My Test Temporal coverage', audience_level: 'My Test Audience level',
        audience_rating: 'My Test Audience rating', annotation: 'My Test Annotation', rights_summary: 'My Test Rights summary' }
    end

    let(:digital_instantiation_attributes) do
      {
        location: 'Test Location',
        rights_summary: 'My Test Rights summary',
        rights_link: 'In Copyright',
        holding_organization: 'WGBH',
        pbcore_xml_doc: "#{Rails.root}/spec/fixtures/sample_instantiation_valid.xml"
      }
    end

    let(:pbcore_xml_doc) { PBCore::InstantiationDocument.parse(File.read("#{Rails.root}/spec/fixtures/sample_instantiation_valid.xml")) }


    # Use contolled vocab to retrieve all title types.
    let(:title_types) { TitleTypesService.new.all_terms }
    let(:description_types) { DescriptionTypesService.new.all_terms }

    # Make an array of [title, title_type] pairs.
    # Ensure there are 2 titles for every title type.
    let(:titles_with_types) do
      (title_types).each_with_index.map { |title_type, i| ["Test #{title_type} Title #{i + 1}", title_type] }
    end

    # Specify a main title.
    let(:main_title) { titles_with_types.first.first.split.join(" ") }

    # Make an array of [description, description_type] pairs.
    # Ensure there are 2 descriptions for every description type.
    let(:descriptions_with_types) do
      (description_types).each_with_index.map { |description_type, i| ["Test #{description_type} Description #{i + 1}", description_type] }
    end

    # Specify a main description.
    let(:main_description) { descriptions_with_types.first.first }

    # Make an array of [date, date_type] pairs.
    # Ensure there are 2 date for every date type.
    let(:dates_with_types) do
      (DateTypesService.all_terms * 2).each_with_index.map { |date_type, i| [rand_date_time.strftime(output_date_format), date_type] }
    end

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
      visit new_hyrax_asset_path

      expect(page).to have_content "Add New Asset"

      click_link "Files" # switch tab
      expect(page).to have_content "Add files"
      expect(page).to have_content "Add folder"

      # validate metadata with errors
      page.find("#required-metadata")[:class].include?("incomplete")

      click_link "Descriptions" # switch tab

      #show all fields groups
      disable_collapse

      fill_in_titles_with_types(titles_with_types)                                # see AssetFormHelper#fill_in_titles_with_types
      fill_in_descriptions_with_types(descriptions_with_types)                    # see AssetFormHelper#fill_in_descriptions_with_types

      # validated metadata without errors
      page.find("#required-metadata")[:class].include?("complete")

      fill_in('Spatial coverage', with: asset_attributes[:spatial_coverage])
      fill_in('Temporal coverage', with: asset_attributes[:temporal_coverage])
      fill_in('Audience level', with: asset_attributes[:audience_level])
      fill_in('Audience rating', with: asset_attributes[:audience_rating])
      fill_in('Annotation', with: asset_attributes[:annotation])
      fill_in('Rights summary', with: asset_attributes[:rights_summary])

      click_link "Relationships" # define adminset relation
      find("#asset_admin_set_id option[value='#{admin_set_id}']").select_option

      # set it public
      find('body').click
      choose('asset_visibility_open')

      expect(page).to have_content('Please note, making something visible to the world (i.e. marking this as Public) may be viewed as publishing which could impact your ability to')

      click_on('Save & Create Digital Instantiation')

      expect(page).to have_content 'Add New Digital Instantiation', wait: 5

      # TODO: Why do we need to call this twice?
      disable_collapse
      disable_collapse

      attach_file('Digital instantiation pbcore xml', File.absolute_path(digital_instantiation_attributes[:pbcore_xml_doc]))
      fill_in('Location', with: digital_instantiation_attributes[:location])

      # Select Holding Organization
      select = page.find('select#digital_instantiation_holding_organization')
      select.select digital_instantiation_attributes[:holding_organization]

      fill_in('Rights summary', with: digital_instantiation_attributes[:rights_summary])

      # fill_in('Rights link', with: digital_instantiation_attributes[:rights_link])
      # select(digital_instantiation_attributes[:rights_link], from: 'Rights link')

      within('.digital_instantiation_rights_link') do
        find('button.multiselect').click
        find('label.checkbox', text: digital_instantiation_attributes[:rights_link]).click
      end

      # set it public
      find('body').click
      choose('digital_instantiation_visibility_open')
      expect(page).to have_content('Please note, making something visible to the world (i.e. marking this as Public) may be viewed as publishing which could impact your ability to')

      click_link "Relationships" # define adminset relation
      find("#digital_instantiation_admin_set_id option[value='#{admin_set_id}']").select_option

      click_on('Save')
      # Wait for the DigitalInstantiation to be saved
      Timeout::timeout(10) { DigitalInstantiation.where(title: digital_instantiation_attributes[:title]).first }

      # Expect page to have the main_title as the DigitalInstantiation's title.
      expect(page).to have_content digital_instantiation_attributes[:main_title]
      expect(page).to have_content digital_instantiation_attributes[:location]
      expect(page).to have_content pbcore_xml_doc.digital.value
      expect(page).to have_content pbcore_xml_doc.media_type.value

      # rights link
      expect(page).to have_content "http://rightsstatements.org/page/InC/1.0/?language=en"
      expect(page).to have_content digital_instantiation_attributes[:rights_summary]
      expect(page).to have_content digital_instantiation_attributes[:holding_organization]
      expect(page).to have_current_path(guid_regex)

      # Go to search page
      visit '/'
      find("#search-submit-header").click

      # Get the Asset record, it's DigitalInstantiation, and it's EssenceTracks
      # in order to test what you see in the search interface.
      asset = Asset.where(title: main_title).first
      digital_instantiation = asset.members.first
      essence_tracks = digital_instantiation.members.to_a

      # Expect to see the Asset in search results.
      expect(page).to have_search_result asset
      # Expect to NOT see the DigitalInstantiation in the search results.
      expect(page).to_not have_search_result digital_instantiation
      # Expect to NOT see the EssenceTracks in the search results.
      essence_tracks.each do |essence_track|
        expect(page).to_not have_search_result essence_track
      end
    end
  end
end
