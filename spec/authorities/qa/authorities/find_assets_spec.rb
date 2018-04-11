require 'rails_helper'

RSpec.describe Qa::Authorities::FindAssets do
  let(:controller) { Qa::TermsController.new }
  let(:user1) { create(:user) }
  # let(:user2) { create(:user) }
  let(:ability) { instance_double(Ability, admin?: false, user_groups: [], current_user: user1) }
  let(:q) { "foo" }
  let(:params) { ActionController::Parameters.new(q: q, id: asset1.id, user: user1.email, controller: "qa/terms", action: "search", vocab: "find_assets") }
  let(:service) { described_class.new }
  let!(:asset1) { create(:asset, title: ['foo']) }
  let!(:asset2) { create(:asset, title: ['foo foo']) }
  # let!(:work3) { create(:generic_work, :public, title: ['bar'], user: user1) }
  # let!(:work4) { create(:generic_work, :public, title: ['another foo'], user: user1) }
  # let!(:work5) { create(:generic_work, :public, title: ['foo foo foo'], user: user2) }

  before do
    allow(controller).to receive(:params).and_return(params)
    allow(controller).to receive(:current_user).and_return(user1)
    allow(controller).to receive(:current_ability).and_return(ability)
  end

  subject { service.search(q, controller) }

  describe '#search' do
    it 'displays a list of all assets' do
      expect(subject.map { |result| result[:id] }).to match_array [asset1.id, asset2.id]
    end
  end
end
