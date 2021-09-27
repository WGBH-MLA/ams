require 'rails_helper'

RSpec.describe SonyCi::WebhookLog, type: :model do
  describe 'validation' do
    subject { build(:sony_ci_webhook_log) }
    context 'when all fields are valid' do
      it { is_expected.to be_valid }
    end

    context 'when response_status not a number between 200 and 599' do
      before { subject.response_status = 'something bogus' }
      it { is_expected.to_not be_valid }
    end

    context 'when URL is empty' do
      it 'is invalid' do
        expect(build(:sony_ci_webhook_log, url: nil)).to_not be_valid
        expect(build(:sony_ci_webhook_log, url: '')).to_not be_valid
      end
    end

    context 'when URL is empty string' do
      before { subject.url = '' }
      it { is_expected.to_not be_valid }
    end

    context 'when action is empty' do
      it 'is invalid' do
        expect(build(:sony_ci_webhook_log, action: nil)).to_not be_valid
        expect(build(:sony_ci_webhook_log, action: '')).to_not be_valid
      end
    end
  end

  describe '#guids' do
    let(:guids) { [ 'cpb-aacip-1234', 'cpb-aacip-5678'] }
    let(:webhook_log) { create(:sony_ci_webhook_log, guids: guids) }
    it 'stores a list of GUIDs as a serialized array' do
      expect(SonyCi::WebhookLog.find(webhook_log.id).guids).to eq guids
    end
  end
end
