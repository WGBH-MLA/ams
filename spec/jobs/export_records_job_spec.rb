require 'rails_helper'

RSpec.describe ExportRecordsJob, type: :job do
  include ActiveJob::TestHelper
  include ActionMailer::TestHelper

  context 'when an exception is raised, ' do
    let(:search_params) { {} }
    # We have to actually create the user because ActiveJob
    # serializes/deserializes the args.
    # TODO: is there a way around this?
    let(:user) { create(:user) }
    let(:most_recent_mail) { ActionMailer::Base.deliveries.last }
    let!(:delivery_count) { ActionMailer::Base.deliveries.count }
    before do
      # Stub the actual perform method.
      allow_any_instance_of(described_class).to receive(:perform).and_raise "Foo"
      # Stub nearest edge of expected side effect.
      allow(Rails.logger).to receive(:error)
    end

    it 'does not retry, and the error is logged' do
      perform_enqueued_jobs do
        described_class.perform_later(search_params, user, 'demo.aapb.wgbh-mla.org')
      end
      assert_performed_jobs 1
      assert_emails delivery_count + 1
      expect(Rails.logger).to have_received(:error).with(/Foo/).exactly(1).times
      expect(most_recent_mail.subject).to eq "AMS2 to AAPB Failed"
    end
  end
end
