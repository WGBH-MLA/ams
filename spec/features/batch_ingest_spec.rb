require 'rails_helper'
# include Warden::Test::Helpers

# TODO: more full-featured specs testing each ingest type will cover the basic
# test to see that it's been installed. After those are added, this can
# probably be removed.
RSpec.feature 'batch ingest plugin', js: false do
  it 'is installed' do
    visit '/batches'
    expect(page.status_code).to eq 200
  end
end
