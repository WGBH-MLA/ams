require 'rails_helper'

RSpec.describe SonyCi::WebhooksController do
  describe 'POST save_sony_ci_id' do
    let(:sony_ci_id) { Faker::Number.hexadecimal(digits: 16) }
    let(:asset) { create(:asset) }
    let(:sony_ci_filename) { "#{asset.id}.mp4" }

    let(:request_body) {
      {
        "id" => Faker::Number.hexadecimal(digits: 16),
        "type" => "AssetProcessingFinished",
        "createdOn" => Time.now.utc.iso8601,
        "createdBy" => {
          "id" => Faker::Number.hexadecimal(digits: 16),
          "name" => "John Smith",
          "email" => "johnsmith@example.com"
        },
        "assets" => [
          {
            "id" => sony_ci_id,
            "name" => "#{sony_ci_filename}"
          }
        ]
      }
    }

    let(:response_body) { JSON.parse(response.body) }

    before do
      post :save_sony_ci_id, params: request_body
    end

    let(:latest_webhook_log) { SonyCi::WebhookLog.last }

    after do
      expect(latest_webhook_log.request_body).to eq request_body
      expect(latest_webhook_log.response_body).to eq response_body
      expect(latest_webhook_log.response_status).to eq 200
    end

    it 'returns a 200 ' \
       'and returns a success message, ' \
       'and saves the Sony Ci ID to the Asset, ' \
       'and creates a WebhookLog record for logging containing the GUID' do
      expect(response.status).to eq 200
      expect(response_body['message']).to match /success/
      expect(asset.admin_data.reload.sonyci_id).to eq [ sony_ci_id ]
      expect(latest_webhook_log.guids).to eq [ asset.id ]
    end

    context 'when the uploaded filename does not resolve to an Asset' do
      let(:sony_ci_filename) { "does-not-match-asset.mp4" }
      it 'responds with a 200 to avoid Sony Ci retries, ' \
          'and responds with the error message, ' \
         'and does NOT save the GUID to the WebhookLog record' do
        expect(response.status).to eq 200
        expect(response_body['error']).not_to be_empty
        expect(latest_webhook_log.guids).to be_empty
      end
    end
  end
end
