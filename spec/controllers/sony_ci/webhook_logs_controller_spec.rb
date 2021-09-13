require 'rails_helper'

RSpec.describe SonyCi::WebhookLogsController, type: :controller do

  render_views

  describe "GET #index" do
    it "returns a success response" do
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    let(:webhook_log) { create(:sony_ci_webhook_log) }
    it "returns a success response" do
      get :show, params: { id: webhook_log.to_param }



      expect(response).to be_successful
    end
  end
end
