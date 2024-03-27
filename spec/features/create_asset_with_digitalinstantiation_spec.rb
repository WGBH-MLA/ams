require 'rails_helper'

RSpec.feature 'Create and Validate AssetResource,Digital Instantiation, EssenseTrack', js: true, turbolinks: true, asset_resource_form_helpers: true,
              disable_animation:true, expand_fieldgroup: true  do
  context 'Create adminset, create asset_resource, import pbcore xml for digital instantiation and essensetrack' do
    let(:admin_user) { create :admin_user }
    let!(:user_with_role) { create :user, role_names: ['ingester'] }
    let(:admin_set) { Hyrax::AdminSetCreateService.find_or_create_default_admin_set }

    let(:input_date_format) { '%m/%d/%Y' }
    let(:output_date_format) { '%F' }

    let(:asset_resource_attributes) do
      { title: "My Test Title"+ get_random_string, description: "My Test Description",spatial_coverage: 'My Test Spatial coverage',
        temporal_coverage: 'My Test Temporal coverage', audience_level: 'My Test Audience level',
        audience_rating: 'My Test Audience rating', annotation: 'My Test Annotation', rights_summary: 'My Test Rights summary' }
    end

    let(:digitial_instantiation_resource_attributes) do
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

    scenario 'Create and Validate AssetResource, Search asset_resource' do
      skip 'TODO fix feature specs'

      admin_set.permission_manager.edit_users = [user_with_role.user_key]
      admin_set.permission_manager.acl.save
      # Login role user to create asset_resource
      login_as(user_with_role)

      # create asset_resource
      visit new_hyrax_asset_resource_path

      expect(page).to have_content "Add New AssetResource"

      click_link "Files" # switch tab
      expect(page).to have_content "Add files"
      expect(page).to have_content "Add folder"

      # validate metadata with errors
      page.find("#required-metadata")[:class].include?("incomplete")

      click_link "Descriptions" # switch tab

      #show all fields groups
      disable_collapse

      fill_in_titles_with_types(titles_with_types)                                # see AssetResourceFormHelper#fill_in_titles_with_types
      fill_in_descriptions_with_types(descriptions_with_types)                    # see AssetResourceFormHelper#fill_in_descriptions_with_types

      # validated metadata without errors
      page.find("#required-metadata")[:class].include?("complete")

      fill_in('Spatial coverage', with: asset_resource_attributes[:spatial_coverage])
      fill_in('Temporal coverage', with: asset_resource_attributes[:temporal_coverage])
      fill_in('Audience level', with: asset_resource_attributes[:audience_level])
      fill_in('Audience rating', with: asset_resource_attributes[:audience_rating])

      # Use ID for asset_resource_annotation on asset_resource since we have related Annotations.
      fill_in('asset_resource_annotation', with: asset_resource_attributes[:annotation])
      fill_in('Rights summary', with: asset_resource_attributes[:rights_summary])

      click_link "Relationships" # define adminset relation

      find("#asset_resource_admin_set_id option[value='#{admin_set_id}']").select_option

      # set it public
      find('body').click
      choose('asset_resource_visibility_open')

      expect(page).to have_content('Please note, making something visible to the world (i.e. marking this as Public) may be viewed as publishing which could impact your ability to')

      click_on('Save & Create Digital Instantiation')

      expect(page).to have_content 'Add New Digital Instantiation', wait: 5

      # TODO: Why do we need to call this twice?
      disable_collapse
      disable_collapse

      attach_file('Digital instantiation pbcore xml', File.absolute_path(digitial_instantiation_resource_attributes[:pbcore_xml_doc]))
      fill_in('Location', with: digitial_instantiation_resource_attributes[:location])

      # Select Holding Organization
      select = page.find('select#digitial_instantiation_resource_holding_organization')
      select.select digitial_instantiation_resource_attributes[:holding_organization]

      fill_in('Rights summary', with: digitial_instantiation_resource_attributes[:rights_summary])

      # fill_in('Rights link', with: digitial_instantiation_resource_attributes[:rights_link])
      # select(digitial_instantiation_resource_attributes[:rights_link], from: 'Rights link')

      within('.digitial_instantiation_resource_rights_link') do
        find('button.multiselect').click
        find('label.checkbox', text: digitial_instantiation_resource_attributes[:rights_link]).click
      end

      # set it public
      find('body').click
      choose('digitial_instantiation_resource_visibility_open')
      expect(page).to have_content('Please note, making something visible to the world (i.e. marking this as Public) may be viewed as publishing which could impact your ability to')

      click_link "Relationships" # define adminset relation
      find("#digitial_instantiation_resource_admin_set_id option[value='#{admin_set_id}']").select_option

      click_on('Save')

      # Expect page to have the main_title as the DigitalInstantiation's title.
      expect(page).to have_content digitial_instantiation_resource_attributes[:main_title]
      expect(page).to have_content digitial_instantiation_resource_attributes[:location]
      expect(page).to have_content pbcore_xml_doc.digital.value
      expect(page).to have_content pbcore_xml_doc.media_type.value

      # rights link
      expect(page).to have_content "http://rightsstatements.org/page/InC/1.0/?language=en"
      expect(page).to have_content digitial_instantiation_resource_attributes[:rights_summary]
      expect(page).to have_content digitial_instantiation_resource_attributes[:holding_organization]
      expect(page).to have_current_path(guid_regex)

      # Go to search page
      visit '/'
      find("#search-submit-header").click

      # Get the AssetResource record, it's DigitalInstantiation, and it's EssenceTracks
      # in order to test what you see in the search interface.
      asset_resource = Hyrax.query_service.find_all_of_model(AssetResource).detect { |a| a.title.include?(main_title) }
      digitial_instantiation_resource = asset_resource.members.first
      essence_tracks = digitial_instantiation_resource.members.to_a

      # Expect to see the AssetResource in search results.
      expect(page).to have_search_result asset_resource
      # Expect to NOT see the DigitalInstantiation in the search results.
      expect(page).to_not have_search_result digitial_instantiation_resource
      # Expect to NOT see the EssenceTracks in the search results.
      essence_tracks.each do |essence_track|
        expect(page).to_not have_search_result essence_track
      end
    end
  end
end
