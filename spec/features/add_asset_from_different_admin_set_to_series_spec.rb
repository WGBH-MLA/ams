require 'rails_helper'

RSpec.feature "AddAssetFromDifferentAdminSetToSeries", type: :feature, js: true, disable_animation:true do

  before { Rails.application.load_seed }

  context 'Create adminset, create series collection' do
    let!(:user) { create :user, role_names: ['user']}

    let!(:admin_set_1) { create :admin_set }
    let(:permission_template_1) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_1.id) }
    let!(:workflow_1) { Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template_1) }

    let!(:admin_set_2) { create :admin_set }
    let(:permission_template_2) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_2.id) }
    let!(:workflow_2) { Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template_2) }

    let!(:asset_1) { create :asset, with_admin_set:true, admin_set_id:admin_set_1.id, user:user}
    let!(:asset_2) { create :asset, with_admin_set:true, admin_set_id:admin_set_2.id, user:user}

    let(:series_collection_attributes) do
      attributes_for :series_collection
    end

    scenario 'Create and Validate Series, Search series' do
      Sipity::WorkflowAction.create!(name: 'submit', workflow: workflow_1)
      Hyrax::PermissionTemplateAccess.create!(
          permission_template_id: permission_template_1.id,
          agent_type: 'group',
          agent_id: 'user',
          access: 'deposit'
      )

      Sipity::WorkflowAction.create!(name: 'submit', workflow: workflow_2)
      Hyrax::PermissionTemplateAccess.create!(
          permission_template_id: permission_template_2.id,
          agent_type: 'group',
          agent_id: 'user',
          access: 'deposit'
      )

      # Login role user to create series
      login_as(user)
      visit hyrax.dashboard_collections_path

      click_on "New Collection"
      expect(find('div.main-header')).to have_content "New Series"
      fill_in('Series title', with: series_collection_attributes[:series_title].first)
      fill_in('Series description', with: series_collection_attributes[:series_description].first)
      click_on('Save')

      wait_for(3) { Collection.where(series_title: series_collection_attributes[:title]).first }

      visit "/concern/assets/#{asset_1.id}"

      click_on I18n.t('hyrax.dashboard.my.action.add_to_collection')

      within('#s2id_member_of_collection_ids') {find('a.select2-choice').click }
      sleep(2)
      find('#s2id_autogen1_search').send_keys(series_collection_attributes[:series_title].first)
      sleep(2)
      expect(find("#select2-results-1")).to have_content series_collection_attributes[:series_title].first
      within('#select2-results-1') {find('span', text: series_collection_attributes[:series_title].first).click}
      click_on 'Save changes'


      visit "/concern/assets/#{asset_2.id}"

      click_on I18n.t('hyrax.dashboard.my.action.add_to_collection')


      within('#s2id_member_of_collection_ids') {find('a.select2-choice').click }
      sleep(2)
      find('#s2id_autogen1_search').send_keys(series_collection_attributes[:series_title].first)
      sleep(2)
      expect(find("#select2-results-1")).to have_content series_collection_attributes[:series_title].first
      within('#select2-results-1') {find('span', text: series_collection_attributes[:series_title].first).click}
      click_on 'Save changes'

      expect(page).to have_content asset_1.title.first
      expect(page).to have_content asset_2.title.first

    end
  end
end
