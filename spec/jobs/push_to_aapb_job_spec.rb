require 'rails_helper'

RSpec.describe PushToAAPBJob, type: :job do
  include ActiveJob::TestHelper

  describe '.perform_now' do
    let(:push) { create(:push, user_id: user.id, status: 'pending') }
    let(:id) { push.id }
    let(:user) { create(:user) }

    let(:delivery_instance) { instance_double(AMS::Export::Delivery::AAPBDelivery) }
    let(:notification_instance) { instance_double(AMS::Export::Notification::PushToAAPBNotification) }

    before do
      # Some mocking of the nearest edges
      allow(delivery_instance).to receive(:deliver)
      allow(notification_instance).to receive(:send_success)
      allow_any_instance_of(described_class).to receive(:delivery).and_return(delivery_instance)
      allow_any_instance_of(described_class).to receive(:notification).and_return(notification_instance)

    end

    context 'when push ids are present' do
      before do
        allow(Push).to receive(:find).and_return(push)
        allow(push).to receive(:push_ids).and_return(Array.new(500) { SecureRandom.uuid })

        # Call the method under test and assert expectations below.
        described_class.perform_now(id: id, user: user)
      end

      it 'call #deliver of its AMS::Export::Delivery::AAPBDelivery instance' do
        expect(delivery_instance).to have_received(:deliver)
        expect(notification_instance).to have_received(:send_success)
      end
    end

    context 'when push ids are not present' do
      before do
        allow(Push).to receive(:find).and_return(push)
        allow(push).to receive(:push_ids).and_return([])

        clear_enqueued_jobs  # clears anything enqueued by factory callbacks
        described_class.perform_now(id: id, user: user)
      end

      it 'reschedules the job' do
        expect(delivery_instance).not_to have_received(:deliver)
        expect(described_class).to have_been_enqueued.with(hash_including(id: push.id, user: user)).exactly(:once)
      end
    end
  end
end
