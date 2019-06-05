require 'rails_helper'
require 'current_user_stub'

RSpec.describe "Pushes", reset_data: true do
  #   let(:ingester_class) { described_class }
  # let(:submitter) { create(:user) }
  # let(:batch) { build(:batch, submitter_email: submitter.email) }
  # let(:sample_source_location) { File.join(fixture_path, 'batch_ingest', 'sample_pbcore2_xml', 'cpb-aacip_600-g73707wt6r.xml' ) }
  # let(:batch_item) { build(:batch_item, batch: batch, source_location: sample_source_location)}


  let(:asset) { create(:asset) }

  context '#pushes' do

    it 'gives validation error when invalid GUID input data' do
      visit '/pushes/new'
      fill_in('id_field', with: 'xxx123' )
      expect(page).to have_text('There was a problem parsing your IDs. Please check your input and try again.')
    end

    it 'gives all clear for valid GUID input data' do
      visit '/pushes/new'
      fill_in('id_field', with: asset.id )
      expect(page).to have_text('All GUIDs are valid!')
    end

    it 'can submit a push successfully' do
      visit '/pushes/new'
      fill_in('id_field', with: asset.id )

      click_button(id: 'push-submit')

      # this will have the output mail
      output_mail = ActionMailer::Base.deliveries.last
      require('pry');binding.pry
    end
  end
end
