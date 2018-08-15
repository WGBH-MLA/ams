require 'rails_helper'

RSpec.feature 'Create and Validate Series Collection', js: true do

  before { Rails.application.load_seed }

  context 'Create adminset, create series collection' do
    let(:admin_user) { create :admin_user }
    let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
    let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
    let!(:workflow) { Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template) }

    let(:series_collection_attributes) do
      attributes_for :series_collection
    end
    #   {
    #     title: "My Test Series",
    #     description: "A test Series for testing!",
    #     audience_level: 'My Test Audience level',
    #     audience_rating: 'My Test Audience rating',
    #     annotation: 'My Test Annotation',
    #     rights_summary: 'My Test Rights summary',
    #     rights_link: 'http://somerightslink.com/testlink'
    #   }
    # end

    scenario 'Create and Validate Series, Search series' do
      Sipity::WorkflowAction.create!(name: 'submit', workflow: workflow)
      Hyrax::PermissionTemplateAccess.create!(
        permission_template_id: permission_template.id,
        agent_type: 'group',
        agent_id: 'user',
        access: 'deposit'
      )
      # Login role user to create series
      login_as(admin_user)
      visit hyrax.dashboard_collections_path

      click_on "New Collection"
      expect(find('div.main-header')).to have_content "New Series"
      fill_in('Series title', with: series_collection_attributes[:series_title].first)
      fill_in('Series description', with: series_collection_attributes[:series_description].first)
      click_on('Save')

      Timeout::timeout(10) { Collection.where(series_title: series_collection_attributes[:title]).first }

      # Go back to the dashboard list of colletions.
      visit hyrax.dashboard_collections_path
      # expect series collection is showing up
      expect(page).to have_content series_collection_attributes[:series_title].first

      # open series collection with detail show
      all('a', text: series_collection_attributes[:series_title].first).first.click
      expect(page).to have_content series_collection_attributes[:series_title].first
      expect(page).to have_current_path(guid_regex)
    end
  end
end
