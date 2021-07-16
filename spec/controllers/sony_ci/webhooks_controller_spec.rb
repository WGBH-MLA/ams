require 'rails_helper'

RSpec.describe SonyCi::WebhooksController do

  # non-memoized shortcut to random hex string
  def randhex(len=32)
    len.times.map { rand(15).to_s(16) }
  end

  describe 'POST save_sony_ci_id' do
    let(:sony_ci_id) { randhex }
    let(:asset) { create(:asset) }
    let(:sony_ci_filename) { "#{asset.id}.mp4" }

    let(:request_body) {
      {
        "id" => randhex,
        "type" => "AssetProcessingFinished",
        "createdOn" => Time.now.utc.iso8601,
        "createdBy" => {
          "id" => randhex,
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
    end

    it 'returns a 200 ' \
       'and returns a success message ' \
       'and saves the Sony Ci ID to the Asset ' \
       'and creates a WebhookRequest record for logging' do
      expect(response.status).to eq 200
      expect(response_body['message']).to match /success/
      expect(asset.admin_data.reload.sonyci_id).to eq [ sony_ci_id ]
    end

    context 'when the uploaded filename does not resolve to an Asset' do
      let(:sony_ci_filename) { "does-not-match-asset.mp4" }
      it 'returns a 200 to avoid Sony Ci retries' \
         'and returns an error message in the body' do
        expect(response.status).to eq 200
        expect(response_body['error']).not_to be_empty
      end
    end
  end
end
