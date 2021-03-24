require 'rails_helper'

RSpec.describe PushToAAPBJob, type: :job do
  describe '.perform_now' do

    let(:ids) { Array.new(500) { SecureRandom.uuid } }
    let(:user) { create(:user) }

    let(:delivery_instance) { instance_double(AMS::Export::Delivery::AAPBDelivery) }
    let(:notification_instance) { instance_double(AMS::Export::Notification::PushToAAPBNotification) }

    before do
      # Some mocking of the nearest edges
      allow(delivery_instance).to receive(:deliver)
      allow(notification_instance).to receive(:send_success)
      allow_any_instance_of(described_class).to receive(:delivery).and_return(delivery_instance)
      allow_any_instance_of(described_class).to receive(:notification).and_return(notification_instance)

      # Call the method under test and assert expectations below.
      described_class.perform_now(ids: ids, user: user)
    end

    it 'call #deliver of its AMS::Export::Delivery::AAPBDelivery instance' do
      expect(delivery_instance).to have_received(:deliver)
      expect(notification_instance).to have_received(:send_success)
    end
  end
end
