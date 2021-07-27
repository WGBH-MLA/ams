require "rails_helper"

RSpec.describe SonyCi::WebhookLogsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/sony_ci/webhook_logs").to route_to("sony_ci/webhook_logs#index")
    end

    it "routes to #show" do
      expect(:get => "/sony_ci/webhook_logs/1").to route_to("sony_ci/webhook_logs#show", :id => "1")
    end
  end
end
