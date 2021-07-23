require 'rails_helper'

RSpec.describe SonyCi::APIController do
  # Defind params to use in GET request.
  let(:params) { { query: "foo" } }
  let(:mock_sony_ci_api) { instance_double(SonyCiApi::Client) }

  before do
    # Use a mock Sony Ci API in the controller.
    allow(controller).to receive(:sony_ci_api).and_return(mock_sony_ci_api)
  end

  # All methods in SonyCi::APIController should catch errors raised by
  # SonyCiApi::Client and render JSON with the error info, and respond with
  # the proper HTTP status.
  shared_examples 'error responses' do |ams_endpoint:, params:|
    # The specific error class, message, and response status are arbitrary, we
    # just are testing to make sure they make get passed on through the response.
    let(:error_msg) { "Some error message" }
    let(:status) { rand(400..599) }
    before do
      # Stub all the instance methods of SonyCiApi::Client to raise an arbitrary
      # error.
      SonyCiApi::Client.instance_methods(false).each do |instance_method|
        allow(mock_sony_ci_api).to receive(instance_method).with(any_args).and_raise(
          SonyCiApi::Error.new(error_msg, http_status: status)
        )
      end

      # call the method under test
      get ams_endpoint, params: params
    end

    it 'responds with proper http code and error info' do
      expect(JSON.parse(response.body)).to eq(
        { "error" => "SonyCiApi::Error", "error_message" => error_msg }
      )
      expect(response.status).to eq status
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
  end

  describe 'GET get_filename' do
    let(:params) { { sony_ci_id: '123' } }

    context 'when Sony Ci API does not raise an error' do
      let(:expected_response) { { 'sony_ci_id' => params[:sony_ci_id], 'name' => 'foo.mp4' } }
      before do
        allow(mock_sony_ci_api).to receive(:asset).with(params[:sony_ci_id]).and_return(
          expected_response
        )
        # call the method under test
        get :get_filename, params: params
      end

      it 'gets the filename for a given Sony Ci ID' do
        expect(JSON.parse(response.body)).to eq expected_response
        expect(response.status).to eq 200
      end
    end

    include_examples 'error responses', ams_endpoint: :get_filename, params: { sony_ci_id: '123' }
  end
end
