require 'rails_helper'

# TODO: move this.
RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end


RSpec.describe SonyCi::APIController do
  # Defind params to use in GET request.
  let(:params) { { query: "foo" } }
  let(:mock_sony_ci_api) { instance_double(SonyCiApi::Client) }
  let(:response_body) { JSON.parse(response.body) }

  before do
    # Use a mock Sony Ci API in the controller.
    allow(controller).to receive(:sony_ci_api).and_return(mock_sony_ci_api)
  end

  # All methods in SonyCi::APIController should catch errors raised by
  # SonyCiApi::Client and render JSON with the error info, and respond with
  # the proper HTTP status.
  shared_examples 'error responses' do |ams_endpoint:, params:|
    # This context is needed to isolate the `before` callback to specs within
    # the shared examples.
    context 'when errors are raised' do
      let(:error_class) { StandardError }
      let(:error_msg) { "bad things man, bad things" }

      before do
        # Force SonyCiApi::Client to raise error_class when any method is called.
        SonyCiApi::Client.instance_methods(false).each do |instance_method|
          allow(mock_sony_ci_api).to receive(instance_method).with(any_args).and_raise(
            error_class,
            error_msg
          )
        end
      end

      it 'responds with a 500 status and error info' do
        # make a request to ams_endpoint (param for the shared examples)
        get ams_endpoint, params: params
        expect(response_body['error']).to eq "StandardError"
        expect(response_body['error_message']).to eq error_msg
        expect(response.status).to eq 500
      end


      context 'when a SonyCiApi::Error is raised' do
        let(:error_class) { SonyCiApi::Error }

        it 'responds with a 500 http status and JSON object containing the error info' do
          # make a request to ams_endpoint with params
          get ams_endpoint, params: params
          expect(response_body['error']).to eq "SonyCiApi::Error"
          expect(response_body['error_message']).to eq error_msg
          expect(response.status).to eq 500
        end
      end

      context 'when a SonyCiApi::HttpError is raised' do
        let(:error_class) { SonyCiApi::HttpError }
        let(:status) { rand(400..599) }

        before do
          allow_any_instance_of(SonyCiApi::HttpError).to receive(:http_status).and_return(status)
        end

        it 'responds with the HTTP status from the error instance' do
          # make a request to ams_endpoint with params
          get ams_endpoint, params: params
          expect(response_body['error']).to eq "SonyCiApi::HttpError"
          expect(response_body['error_message']).to eq error_msg
          expect(response.status).to eq status
        end
      end
    end
  end

  describe 'GET find_media' do
    before do
      # the find_media action calls SonyCiApi::Client#workspace_search, so mock
      # that here as well.
      allow(mock_sony_ci_api).to receive(:workspace_search).with(
        hash_including(params)
      )
      # Call the action under test.
      get :find_media, params: params
    end

    context 'with :query param that returns results from Sony Ci API' do
      it 'returns a 200 ' do
        expect(response.status).to eq 200
      end
    end

    # Run the 'error responses' shared specs for this endpoint.
    include_examples 'error responses', ams_endpoint: :find_media, params: { query: 'foo' }
  end

  describe 'GET get_filename' do
    let(:params) { { sony_ci_id: '123' } }
    let(:mock_response) {
      { 'sony_ci_id' => params[:sony_ci_id], 'name' => 'foo.mp4' }
    }

    before do
      allow(mock_sony_ci_api).to receive(:asset).with(params[:sony_ci_id]).and_return(
        mock_response
      )
    end

    # Only use response_body after the request has been made, otherwise it won't
    # have the real response in it.
    let(:response_body) { JSON.parse(response.body) }

    it 'gets the filename for a given Sony Ci ID' do
      get :get_filename, params: params
      expect(response_body).to eq mock_response
      expect(response.status).to eq 200
    end

    context 'when missing the :sony_ci_id param' do
      let(:params) { {} }

      it 'returns a JSON for 400 Bad Request and says which param is missing' do
        get :get_filename, params: params
        expect(response_body['error_message']).to include 'sony_ci_id'
        expect(response.status).to eq 400
      end
    end

    include_examples 'error responses', ams_endpoint: :get_filename, params: { sony_ci_id: '123' }
  end
end
