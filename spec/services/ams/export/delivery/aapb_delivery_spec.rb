require 'rails_helper'

RSpec.describe AMS::Export::Delivery::AAPBDelivery do
  # Create an instance double of an anonymous subclass of AMS::Export::Results::Base
  # that our test subject can use.
  # let(:fake_export_results) do
  #   instance_double(Class.new(AMS::Export::Results::Base)).tap do |fake|
  #     # Mock the parts of the interface used by our test subject.
  #     allow(fake).to receive(:filepath).and_return('/fake_dir/fake_export.xyz')
  #     allow(fake).to receive(:content_type).and_return('fake/type')
  #   end
  # end

  let(:assets) { create_list(:asset_resource, rand(2..4)) }

  let(:solr_documents) do
    assets.map { |asset| SolrDocument.new(asset.to_solr) }
  end

  let(:export_results) do
    AMS::Export::Results::PBCoreZipResults.new(solr_documents: solr_documents)
  end

  # Create test subject using the fake export results object.
  # subject { described_class.new(export_results: fake_export_results) }
  subject { described_class.new(export_results: export_results) }

  # NOTE: #ingester is private but we need make sure it's been created with the
  # correct parameters.
  describe '#ingester' do
    let(:ingester) { subject.send(:ingester) }
    # AAPBDelivery uses ENV vars to configure the AAPBRemoteIngester, so mock
    # those here.
    before do
      ENV['AAPB_HOST'] = 'fake-host.org'
      ENV['AAPB_SSH_KEY'] = 'fake-key'
    end

    it 'returns an AMS::AAPBRemoteIngester instance configured with ENV vars' do
      expect(ingester.host).to eq 'fake-host.org'
      expect(ingester.ssh_key).to eq 'fake-key'
    end
  end

  describe '#deliver' do
    # Mock the AAPBRemoteIngester used by the object under test.
    let(:ingester) { instance_double(AMS::AAPBRemoteIngester) }

    before do
      # Mock the AAPBRemoteIngester methods used by the subject.
      allow(ingester).to receive(:run!)
      allow(ingester).to receive(:output).and_return('fake output')

      # Make the subject use the mock ingester
      allow(subject).to receive(:ingester).and_return(ingester)

      # Grab a timestamp just before delivering, so we can test to make sure
      # the last_pushed date for the records is updated to something afterward.
      @just_before_delivery = Time.now.to_i
      # call the method under test
      subject.deliver
    end

    it 'calls AAPBRemoteIngester#run!' do
      expect(ingester).to have_received(:run!).exactly(1).times
    end

    it 'populates the #notification_data with the remote ingest output' do
      expect(subject.notification_data[:remote_ingest_output]).to eq 'fake output'
    end

    # Get the last_pushed timestamps for comparison to @just_before_delivery.
    # Convert to integers to avoid comparing dates with nil values.
    let(:last_pushed_timestamps) do
      # NOTE: reload is required because update happens after we already create
      # the AdminData instances in memory.
      assets.map { |asset| asset.admin_data.reload.last_pushed.to_i }
    end

    it 'updates the :last_pushed value to the current time for each asset' do
      expect(last_pushed_timestamps).to all( be >= @just_before_delivery )
    end
  end
end
