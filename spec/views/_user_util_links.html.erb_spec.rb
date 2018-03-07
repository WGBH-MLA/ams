require 'rails_helper'

RSpec.describe '/_user_util_links.html.erb', type: :view do
  let(:user) { create(:user) }
  before do
    allow(view).to receive(:user_signed_in?).and_return(true)
    allow(view).to receive(:current_user).and_return(user)
    render
  end
  it 'links to edit registration path' do
    expect(rendered).to match /Change password/
  end
end
