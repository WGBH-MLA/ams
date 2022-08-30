require 'rails_helper'

RSpec.describe "sony_ci/webhook_logs/show", type: :view do
  let(:webhook_log) { create(:sony_ci_webhook_log) }
  let(:presenter) { SonyCi::WebhookLogPresenter.new(webhook_log) }
  before(:each) do
    assign(:presenter, presenter)
    render
  end

  it 'displays the Date, Action, URL, Request Headers, Request Body, ' \
     'Response Headers, Response Body, and the Error, if present' do
    expect(rendered).to include presenter.created_at
    expect(rendered).to include presenter.action
    expect(rendered).to include presenter.url
  end
end
