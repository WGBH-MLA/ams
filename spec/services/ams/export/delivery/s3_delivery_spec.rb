require 'rails_helper'

RSpec.describe AMS::Export::Delivery::S3Delivery do
  # Create an instance of an anonymous subclass of AMS::Export::Results::Base
  # that our test subject can use.
  let(:fake_export_results) do
    instance_double(Class.new(AMS::Export::Results::Base)).tap do |fake|
      # Mock he nearest edge of the fake export results object used by our test
      # subject.
      allow(fake).to receive(:filepath).and_return('/fake_dir/fake_export.xyz')
      allow(fake).to receive(:content_type).and_return('fake/type')
    end
  end

  # Create an instance of Aws::S3::Object that our test subject can use.
  let(:fake_s3_object) do
    instance_double(Aws::S3::Object).tap do |fake|
      # Mock the nearest edge of the fake S3 object used by our test
      # subject.
      allow(fake).to receive(:upload_file).with(any_args)
      allow(fake).to receive(:public_url).with(any_args)
    end
  end

  # Create test subject using the fake export results object.
  subject do
    described_class.new(export_results: fake_export_results).tap do |it|
      # Make the test subject use the fake S3 object.
      allow(it).to receive(:object).and_return(fake_s3_object)
    end
  end

  describe '#deliver' do
    # Run the method under test
    before { subject.deliver }

    it 'sends an export file to S3' do
      expect(fake_s3_object).to have_received(:upload_file).with('/fake_dir/fake_export.xyz',
        acl: 'public-read',
        content_disposition: 'attachment',
        content_type: 'fake/type'
      )
    end
  end
end
