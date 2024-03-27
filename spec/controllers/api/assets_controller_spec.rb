require 'rails_helper'

RSpec.describe API::AssetsController, controller: true do
  describe 'GET /api/assets/{id}' do
    let(:password) { "abc123" }
    let(:user) { create(:user, password: password) }
    let(:encoded_username_and_password) { Base64.encode64("#{request_username}:#{request_password}").strip }
    let(:format) { :json }

    before do
      request.headers['Authorization'] = "Basic #{encoded_username_and_password}"
      get :show, params: { id: asset_id }, format: format
    end

    context 'when username is wrong,' do
      let(:request_password) { password }
      let(:request_username) { 'wrong username' }
      let(:asset_id) { 'anything' }
      it 'returns a 401' do
        expect(response.status).to eq 401
      end
    end

    context 'when password is wrong,' do
      let(:request_username) { user.user_key }
      let(:request_password) { 'wrong password' }
      let(:asset_id) { 'anything' }
      it 'returns a 401' do
        expect(response.status).to eq 401
      end
    end

    context 'when username and password are correct,' do
      let(:request_username) { user.user_key}
      let(:request_password) { password }

      context 'when an Asset exists' do
        let(:asset) { create(:asset) }
        let(:asset_id) { asset.id }
        let(:pbcore_xml) { SolrDocument.find(asset_id).export_as_pbcore }

        context 'when the format is .json' do
          let(:format) { :json }
          let(:pbcore_json) { Hash.from_xml(pbcore_xml).to_json }

          it 'responds with a 200 status' do
            expect(response.status).to eq 200
          end

          it 'response with the JSON for an Asset' do
            expect(response.body).to eq pbcore_json
          end
        end

        context 'when the format is .xml' do
          let(:format) { :xml }

          it 'responds with a 200 status' do
            expect(response.status).to eq 200
          end

          it 'responds with the PBCore XML for an Asset' do
            pbcore_xml = SolrDocument.find(asset.id).export_as_pbcore
            expect(response.body).to eq pbcore_xml
          end
        end
      end
    end
  end
end
