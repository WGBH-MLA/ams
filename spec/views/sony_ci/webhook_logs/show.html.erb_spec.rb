require 'rails_helper'

RSpec.describe "sony_ci/webhook_logs/show", type: :view do
  before(:each) do
    @sony_ci_webhook_log = assign(:sony_ci_webhook_log, SonyCi::WebhookLog.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
