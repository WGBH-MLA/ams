require 'rails_helper'
# include Warden::Test::Helpers

RSpec.feature 'batch ingest plugin', js: false do
  it 'is installed' do
    visit '/'
    expect(page.status_code).to eq 200
  end
end
