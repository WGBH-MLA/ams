require 'rails_helper'

RSpec.feature "Add assets from different admin sets to the a Series collection", type: :feature, js: true, disable_animation: true do
  let(:user) { create :user, role_names: ['test_user_role']}

  let(:admin_set_1) { create :admin_set, title: ["Test Admin Set 1"], with_permission_template: { with_active_workflow: true } }
  let(:admin_set_2) { create :admin_set, title: ["Test Admin Set 2"], with_permission_template: { with_active_workflow: true } }

  let(:asset_1) { create :asset, admin_set: admin_set_1, user: user}
  let(:asset_2) { create :asset, admin_set: admin_set_2, user: user}

  let(:series_collection_attributes) do
    attributes_for :series_collection
  end

  scenario 'Create and Validate Series, Search series' do
    # Login role user to create series
    login_as(user)

    visit hyrax.new_dashboard_collection_path(collection_type_id: Hyrax::CollectionType.find_by_machine_id('series').id)
    expect(find('div.main-header')).to have_content "New Series"
    fill_in('Series title', with: series_collection_attributes[:series_title].first)
    fill_in('Series description', with: series_collection_attributes[:series_description].first)
    click_on('Save')

    wait_for(3) { Collection.where(series_title: series_collection_attributes[:title]).first }

    # Go to the #show page for asset_1
    visit "/concern/assets/#{asset_1.id}"
    # Click on 'Add to collection'
    click_on I18n.t('hyrax.dashboard.my.action.add_to_collection')

    # Click on the auto complete autocomplete select box to select a Series collection.
    find('#s2id_member_of_collection_ids a.select2-choice').click
    # Type in the name of the Series collection.
    find('#s2id_autogen1_search').send_keys(series_collection_attributes[:series_title].first)
    wait_for_ajax
    # Select the series from the drop down.
    find('#select2-results-1 span.select2-match').click
    # Save the changes.
    click_on 'Save changes'

    visit "/concern/assets/#{asset_2.id}"
    click_on I18n.t('hyrax.dashboard.my.action.add_to_collection')

    # Click on the auto complete autocomplete select box to select a Series collection.
    find('#s2id_member_of_collection_ids a.select2-choice').click
    # Type in the name of the Series collection.
    find('#s2id_autogen1_search').send_keys(series_collection_attributes[:series_title].first)
    wait_for_ajax
    # Select the series from the drop down.
    find('#select2-results-1 span.select2-match').click
    # Save the changes.
    click_on 'Save changes'

    # Expect to be redirect to the dashboard collections page
    expect(current_path).to match /#{hyrax.dashboard_collections_path}/

    # And expect to see the two newly added assets.
    expect(page).to have_content asset_1.title.first
    expect(page).to have_content asset_2.title.first
  end
end
