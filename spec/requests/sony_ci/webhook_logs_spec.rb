require 'rails_helper'

RSpec.describe "SonyCi::WebhookLogs", type: :request do
  describe "GET /sony_ci/webhook_logs" do
    it "works! (now write some real specs)" do
      get sony_ci_webhook_logs_path
      expect(response).to have_http_status(200)
    end
  end
end
