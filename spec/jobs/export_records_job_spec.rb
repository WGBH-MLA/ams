require 'rails_helper'

RSpec.describe ExportRecordsJob, type: :job do
  # The ExportRecordsJob uses several external dependencies, and we want to test
  # the calls to those dependencies, which mean lots of mocking, so here we go.

  # Create mock service classes for Search, Results, and Delivery that
  # extend their respective base classes.
  let(:search_class)       { Class.new(AMS::Export::Search::Base) }
  let(:results_class)      { Class.new(AMS::Export::Results::Base) }
  let(:delivery_class)     { Class.new(AMS::Export::Delivery::Base) }
  let(:notification_class) { Class.new(AMS::Export::Notification::Base) }

  # Create mock instances to be returned when calling .new on the mock
  # service classes above.
  let(:search_instance)       { instance_double(search_class) }
  let(:results_instance)      { instance_double(results_class) }
  let(:delivery_instance)     { instance_double(delivery_class) }
  let(:notification_instance) { instance_double(notification_class) }

  # Create a mock arbitrary export type.
  let(:export_type) { :mock_export_type }

  # Create a user that will be used when performing the search and when
  # sending notifications.
  let(:user) { create(:user) }

  # Change these params as needed in contexts below.
  let(:search_params) { {} }

  # Now mock method calls that tie the mock object together.
  before do
    # Mock the calls to the factory method #for_export_type for the various
    # services, and have them return the mock service classes.
    allow(AMS::Export::Search).to receive(:for_export_type).with(export_type).and_return(search_class)
    allow(AMS::Export::Results).to receive(:for_export_type).with(export_type).and_return(results_class)
    allow(AMS::Export::Delivery).to receive(:for_export_type).with(export_type).and_return(delivery_class)
    allow(AMS::Export::Notification).to receive(:for_export_type).with(export_type).and_return(notification_class)

    # Mock method calls to the mock service instances that are called within
    # ExportRecordsJob#perform
    allow(search_instance).to receive(:solr_documents)
    allow(delivery_instance).to receive(:deliver)
    allow(delivery_instance).to receive(:notification_data)
    allow(notification_instance).to receive(:send_failure)
    allow(notification_instance).to receive(:send_success)

    # Set the mock service classes to return the mock instances of those classes.
    allow(search_class).to        receive(:new).
                                  with(search_params: search_params, user: user).
                                  and_return(search_instance)
    allow(results_class).to       receive(:new).
                                  with(solr_documents: search_instance.solr_documents).
                                  and_return(results_instance)
    allow(delivery_class).to      receive(:new).
                                  with(export_results: results_instance).
                                  and_return(delivery_instance)
    allow(notification_class).to  receive(:new).
                                  with(user: user, delivery: delivery_instance).
                                  and_return(notification_instance)

    # Mock the Rails logger
    allow(Rails.logger).to receive(:error)
  end

  # Because we're dealing with ActiveJob, the method under test is the instance
  # method #perform, but it will be invoked with one of two class methods,
  # either .perform_now or .perform_later.
  describe '#perform' do
    context 'when an exception is raised' do
      before do
        # Stub the actual #perform method to raise an arbitrary error.
        allow_any_instance_of(described_class).to receive(:perform).and_raise "Foo"

        # Call the method under test and expect calls to other services in the
        # example below.
        described_class.perform_now(export_type: export_type,
                                    search_params: search_params,
                                    user: user)
      end

      it 'rescues from the exception (i.e. does not retry), logs the error, ' \
         'and sends an email indicating failure.' do
        expect(Rails.logger).to have_received(:error).with(/Foo/).exactly(1).times
        expect(notification_instance).to have_received(:send_failure).exactly(1).times
      end
    end

    context 'when no error is raised' do
      before do
        # Call the method under test before running the test, and  expect calls
        # to external services in the example below.
        described_class.perform_now(export_type: export_type, search_params: search_params, user: user)
      end

      it 'uses the Delivery factory to create a delivery object with the ' \
         'results, calls #deliver on it, and sends the right email' do
        expect(AMS::Export::Delivery).to have_received(:for_export_type).with(export_type).exactly(1).times
        expect(delivery_class).to have_received(:new).with(export_results: results_instance).exactly(1).times
        expect(delivery_instance).to have_received(:deliver).exactly(1).times
        expect(notification_instance).to have_received(:send_success).exactly(1).times
      end
    end
  end
end
