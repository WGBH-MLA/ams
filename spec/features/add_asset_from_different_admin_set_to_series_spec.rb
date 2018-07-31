require 'rails_helper'

RSpec.feature "Add assets from different admin sets to the a Series collection", type: :feature, js: true, disable_animation: true do
  let(:user) { create :user, role_names: ['test_user_role']}

  let(:admin_set_1) { create :admin_set, title: ["Test Admin Set 1"], with_permission_template: { with_active_workflow: true } }
  let(:admin_set_2) { create :admin_set, title: ["Test Admin Set 2"], with_permission_template: { with_active_workflow: true } }

  let(:asset_1) { create :asset, admin_set: admin_set_1, user: user}
  let(:asset_2) { create :asset, admin_set: admin_set_2, user: user}

  let!(:series) { create :series_collection, user: user, with_permission_template: true}


  scenario 'Create and Validate Series, Search series' do
    # Login role user to create series
    login_as(user)

    # Go to the #show page for asset_1
    visit "/concern/assets/#{asset_1.id}"
    # Click on 'Add to collection'
    click_on I18n.t('hyrax.dashboard.my.action.add_to_collection')

    select_collection(series)
    # Save the changes.
    click_on 'Save changes'

    visit "/concern/assets/#{asset_2.id}"
    click_on I18n.t('hyrax.dashboard.my.action.add_to_collection')

    select_collection(series)
    # Save the changes.
    click_on 'Save changes'

    # Expect to be redirect to the dashboard collections page
    expect(current_path).to match /#{hyrax.dashboard_collections_path}/

    # And expect to see the two newly added assets.
    expect(page).to have_content asset_1.title.first
    expect(page).to have_content asset_2.title.first
  end
end
