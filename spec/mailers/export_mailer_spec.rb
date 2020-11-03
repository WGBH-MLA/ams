require "rails_helper"

RSpec.describe ExportMailer, type: :mailer do
  # Use for #have_css and other matchers for HTML content.
  include Capybara::RSpecMatchers

  let(:user) { create(:user) }
  # :mail_data gets merged with the user and passed to the ExportMailer.with
  # to create a parameterized mailer. Set mail_data in the different contexts
  # below.
  let(:mail_data) { {} }
  let(:mailer) { described_class.with(mail_data.merge(user: user)) }


  # describe ".export_to_s3_succeeded" do
  #
  #   let(:fake_download_url) { 'https://fake-host.com/fake-export.ext' }
  #
  #
  #
  #   it "renders the headers" do
  #     expect(mail.subject).to eq "AMS export to S3 is ready for download"
  #     expect(mail.to).to eq [ user.email ]
  #     expect(mail.from).to eq [ "aapb_notifications@wgbh.org" ]
  #   end
  #
  #   it "renders the body" do
  #     expect(mail.body).to match "AMS export to S3 is ready for download"
  #     expect(mail.body.encoded).to have_link(fake_download_url, href: fake_download_url)
  #   end
  # end


  # shortcut matcher for :to, :subject, and mail body content

  describe '#push_to_aapb_failed' do
    let(:mail) { mailer.push_to_aapb_failed }
    let(:mail_data) { { error_message: "Mock Error Message" } }
    it 'has the correct subject, content, and email address' do
      expect(mail.to).to include user.email
      expect(mail.subject).to eq 'Export to AAPB Failed'
      expect(mail.body.encoded).to have_content mail_data[:error_message]
    end
  end

  describe '#push_to_aapb_succeeded' do
    let(:mail) { mailer.push_to_aapb_succeeded }
    let(:mail_data) { { remote_ingest_output: "Mock Remote Ingester Output" } }
    it 'has the correct subject, content, and email address' do
      expect(mail.to).to include user.email
      expect(mail.subject).to eq 'Export to AAPB Succeeded'
      expect(mail.body.encoded).to have_content mail_data[:remote_ingest_output]
    end
  end

  describe '#export_to_s3_failed' do
    let(:mail) { mailer.export_to_s3_failed }
    let(:mail_data) { { error_message: "Mock Error Message" } }
    it 'has the correct subject, content, and email address' do
      expect(mail.to).to include user.email
      expect(mail.subject).to eq 'Export to S3 Failed'
      expect(mail.body.encoded).to have_content mail_data[:error_message]
    end
  end

  describe '#export_to_s3_succeeded' do
    let(:mail) { mailer.export_to_s3_succeeded }
    let(:mail_data) { { download_url: "https://mock-export-url.org/mock-export.zip" } }
    it 'has the correct subject' do
      expect(mail.to).to include user.email
      expect(mail.subject).to eq 'AMS export to S3 is ready for download'
      expect(mail.body.encoded).to have_content mail_data[:download_url]
    end
  end
end
