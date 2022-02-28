# Generated via
#  `rails generate hyrax:work Asset`
require 'rails_helper'

RSpec.describe SonyCi::WebhookLogPresenter do

  let(:webhook_log) {
    create(:sony_ci_webhook_log, action: 'save_sony_ci_id')
  }
  let(:presenter) do
    described_class.new(webhook_log)
  end

  describe '#created_at' do
    it 'returns the created_at timestamp field formatted to mm/dd/yyyy hh:mm:ss am/pm' do
      expected_date_str = webhook_log.created_at.strftime(described_class::DATETIME_FORMAT)
      expect(presenter.created_at).to eq expected_date_str
    end
  end

  describe '#action' do
    it 'returns a user-friendly name of the action performed' do
      expect(presenter.action).to eq 'Link Asset to Sony Ci Media'
    end
  end

  describe '#status' do
    context 'when there is an error present' do
      let(:webhook_log) { create(:sony_ci_webhook_log, error: "Some error") }
      it 'returns "Fail"' do
        expect(presenter.status).to eq "Fail"
      end
    end
  end

  describe '#status' do
    context 'when there is not an error present' do
      let(:webhook_log) { create(:sony_ci_webhook_log, error: nil) }
      it 'returns "Success"' do
        expect(presenter.status).to eq "Success"
      end
    end
  end
end
