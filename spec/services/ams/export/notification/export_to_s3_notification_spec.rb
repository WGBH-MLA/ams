require 'rails_helper'

RSpec.describe AMS::Export::Notification::ExportToS3Notification do
  let(:user) { create(:user) }
  let(:notification_data) { { } }         # overwrite in contexts below
  let(:expected_mail_params) { { } }      # overwrite in contexts below
  let(:expected_mail_action) { { } }      # overwrite in contexts below
  let(:delivery) { instance_double(AMS::Export::Delivery::Base, notification_data: notification_data) }
  let(:mock_mail) { double(deliver_now: nil) }
  let(:mock_mailer) { double }


  before do
    allow(ExportMailer).to receive(:with).
                           with(expected_mail_params).
                           and_return(mock_mailer)
    allow(mock_mailer).to receive(expected_mail_action).and_return(mock_mail)
  end

  let(:subject) { described_class.new(user: user, delivery: delivery) }

  describe '#send_failure' do
    let(:expected_mail_action) { :export_to_s3_failed }
    let(:error_message) { 'mock error message' }
    let(:expected_mail_params) do
      { user: user,
        error_message: error_message }
    end
    # Call the method under test.
    before { subject.send_failure(error_message: error_message) }

    it 'sends the email to the user, with the error message' do
      expect(ExportMailer).to have_received(:with).with(expected_mail_params).exactly(1).times
      expect(mock_mail).to have_received(:deliver_now).exactly(1).times
    end
  end

  describe '#send_success' do
    let(:notification_data) { { download_url: 'https://fake-url.org/fake-export.zip' } }
    let(:expected_mail_action) { :export_to_s3_succeeded }
    let(:expected_mail_params) do
      { user: user,
        download_url: notification_data[:download_url] }
    end

    # Call the method under test.
    before { subject.send_success }

    it 'sends the success email to the user with the remote ingest output' do
      expect(ExportMailer).to have_received(:with).with(expected_mail_params).exactly(1).times
      expect(mock_mail).to have_received(:deliver_now).exactly(1).times
    end
  end
end
