# frozen_string_literal: true
require 'rails_helper'

RSpec.describe MediaController, type: :controller do
  describe 'GET #show' do
    let(:id) { '1234' }
    let(:sony_ci_id) { '4567' }
    let(:fake_sony_ci_url) { "https://fakesonyci.com/download/#{sony_ci_id}"}
    let(:fake_sony_ci_api) { instance_double(SonyCiApi::Client) }
    let(:fake_sony_ci_response) {
      { 'id' => sony_ci_id, 'location' => fake_sony_ci_url }
    }
    let(:fake_solr_document) { { 'sonyci_id_ssim' => [sony_ci_id] } }

    before do
      allow(fake_sony_ci_api).to receive(:asset_download).with(sony_ci_id).and_return(fake_sony_ci_response)
      allow(controller).to receive(:ci).and_return(fake_sony_ci_api)
      allow(SolrDocument).to receive(:find).with(id).and_return(fake_solr_document)
      allow(controller).to receive(:can?).with(:show, fake_solr_document).and_return(true)
    end

    context 'when no Solr document is found for the given :id' do
      before do
        allow(SolrDocument).to receive(:find).with(id).and_raise(Blacklight::Exceptions::RecordNotFound)
      end
      it 'a 404 HTTP status is returned' do
        get :show, params: { id: id }
        expect(response).to have_http_status 404
      end
    end

    context 'when a Solr document is found for the given :id' do
      context 'and when user has permission to view the file' do
        it 'the SonyCiApi is used to fetch the media url' do
          get :show, params: { id: id }
          expect(fake_sony_ci_api).to have_received(:asset_download).with(sony_ci_id)
          expect(response).to redirect_to fake_sony_ci_url
        end

        context 'but the Sony Ci Api responds with any SonyCiApi::HttpError' do
          let(:http_status) { rand(400..599) }
          before do
            allow(fake_sony_ci_api).to receive(:asset_download).and_raise(SonyCiApi::HttpError)
            allow_any_instance_of(SonyCiApi::HttpError).to receive(:http_status).and_return(http_status)
          end
          it 'returns no response and status from SonyCiApi::HttpError#http_status' do
            get :show, params: { id: id }
            expect(response).to have_http_status http_status
            expect(response.body).to be_empty
          end
        end
      end

      context 'and when user does NOT have permission to view the file' do
        # Pretend the user doesn't have permisison to view the Solr document
        before { allow(controller).to receive(:can?).with(:show, fake_solr_document).and_return(false) }
        it 'a 403 HTTP status is returned' do
          get :show, params: { id: id }
          expect(response).to have_http_status 403
          expect(response.body).to be_empty
        end
      end
    end
  end
end
