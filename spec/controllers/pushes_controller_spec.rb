require 'rails_helper'

RSpec.describe PushesController, type: :controller do
  # Use a real memoized method to generate test user once.
  let!(:user) { create :admin_user }

  # Use a real memoized method to generate test asset_resources once.
  let!(:asset_resources) { create_list :asset_resource, rand(2..4), validation_status_for_aapb: [AssetResource::VALIDATION_STATUSES[:valid]] }

  # Ensure user is signed in before each test.
  before { sign_in(user) }

  describe 'GET /pushes/index' do
    render_views
    let(:pushes) { create_list(:push, rand(2..4), user: user) }

    before do
      pushes
      get :index
    end

    it 'assigns @pushes to all Push model instances' do
      expect(assigns(:pushes)).to eq pushes
    end
  end

  describe 'GET /pushes/:id' do
    render_views
    let(:push) { create(:push, user: user, pushed_id_csv: asset_resources.first.id) }

    before { get :show, params: { id: push.id } }
    it 'assign @push to the Push instance for the ID given' do
      expect(assigns(:push)).to eq push
    end
  end

  describe 'GET /pushes/new' do
    render_views
    let(:params) { {} }
    let(:only_whitespace) { /\A\s*\Z/ }
    before { get :new, params: params }
    context 'with no params' do
      it 'renders the "new" view with an empty text box for GUIDs' do
        expect(response.body).to have_css("textarea", text: only_whitespace)
      end
    end

    context 'with search params' do
      # An empty :q in the search just returns all results.
      let(:params) { {q: ''} }

      # Extract the IDs from the rendered textarea
      let(:actual_ids) do
        page = Capybara::Node::Simple.new(response.body)
        page.find('textarea').text.split(/\s+/).reject(&:empty?)
      end

      it 'performs the search to get the IDs, and renders the "new" view with' \
        'the IDs in the id_field' do
          expect(Set.new(actual_ids)).to eq Set.new(asset_resources.map { |v| v.id.to_s })
      end
    end
  end

  describe 'POST /pushes/validate_ids' do
    before { post :validate_ids, params: { id_field: id_field } }
    let(:json_response) { JSON.parse(response.body) }

    context 'with some invalid IDs' do
      let(:asset_resource_ids) { asset_resources.map(&:id) }
      let(:missing_ids) { ["cpb-aacip-xxxxxxxxxxx", "cpb-aacip-xxxxxxxxxxx", "cpb-aacip-yyyyyyyyyyy"] }
      let(:id_field) { (asset_resource_ids + missing_ids).shuffle.join("\n") }
      it 'returns error message that includes the invalid IDs but not any valid
          IDs' do
        missing_ids.each do |missing_id|
          expect(json_response['error']).to include missing_id
        end

        asset_resource_ids.each do |asset_resource_id|
          expect(json_response['error']).not_to include asset_resource_id
        end
      end
    end

    context 'with valid ids' do
      let(:id_field) { asset_resources.map(&:id).join("\n") }
      it 'returns no error' do
        expect(json_response).not_to have_key('error')
      end
    end
  end

  describe 'POST /pushes/create' do
    let(:asset_resource_ids) { asset_resources.map(&:id) }
    # Simulate a list of IDs passed into the id_field param.
    let(:params) { { id_field: asset_resource_ids.join("\n") } }

    # The params with which we expect to run the PushToAAPBJob
    let(:expected_job_params) { { user: user, ids: asset_resource_ids } }

    # Hook up the mocks
    before do
      allow(PushToAAPBJob).to receive(:perform_later).with(expected_job_params)
    end

    it 'creates a new Push instance and calls :perform_later on ' \
      'ExportRecordJob with correct search params' do
      expect { post :create, params: params }.to change { Push.count }.by(1)
      expect(PushToAAPBJob).to have_received(:perform_later).
                              with(expected_job_params).
                              exactly(1).times
    end
  end
end
