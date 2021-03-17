require 'rails_helper'

RSpec.describe AMS::Export::Notification::PushToAAPBNotification do
  let(:user) { create(:user) }
  let(:notification_data) { {} }
  let(:delivery) { instance_double(AMS::Export::Delivery::Base, notification_data: notification_data) }
  let(:mock_mail) { double(deliver_now: nil) }
  let(:mock_mailer) { double }
  # overwrite in contexts
  let(:expected_mail_action) { nil }
  # overwrite in contexts
  let(:expected_mail_params) { { } }

  let(:subject) { described_class.new(user: user, delivery: delivery) }

  before do
    # Tie the mailer mocks together
    allow(ExportMailer).to receive(:with).
                           with(expected_mail_params).
                           and_return(mock_mailer)
    allow(mock_mailer).to receive(expected_mail_action).and_return(mock_mail)
  end

  describe '#send_failure' do
    let(:error_message) { 'mock error message' }
    let(:expected_mail_action) { :push_to_aapb_failed }
    let(:expected_mail_params) do
      { user: user,
        error_message: error_message }
    end


    before do
      # Call the method under test.
      subject.send_failure(error_message: error_message)
    end

    it 'sends the email to the user, with the error message' do
      expect(ExportMailer).to have_received(:with).with(expected_mail_params).exactly(1).times
      expect(mock_mail).to have_received(:deliver_now).exactly(1).times
    end
  end

  describe '#send_success' do
    let(:notification_data) { { remote_ingest_output: "mock output" } }
    let(:expected_mail_action) { :push_to_aapb_succeeded }
    let(:expected_mail_params) do
      { user: user,
        remote_ingest_output: notification_data[:remote_ingest_output] }
    end

    before { subject.send_success }

    it 'sends the success email to the user with the remote ingest output' do
      expect(ExportMailer).to have_received(:with).with(expected_mail_params).exactly(1).times
      expect(mock_mail).to have_received(:deliver_now).exactly(1).times
    end
  end
end
