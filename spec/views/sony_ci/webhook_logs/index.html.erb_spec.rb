require 'rails_helper'

RSpec.describe "sony_ci/webhook_logs/index", type: :view do
  before(:each) do
    assign(:sony_ci_webhook_logs, [
      SonyCi::WebhookLog.create!(),
      SonyCi::WebhookLog.create!()
    ])
  end

  it "renders a list of sony_ci/webhook_logs" do
    render
  end
end
