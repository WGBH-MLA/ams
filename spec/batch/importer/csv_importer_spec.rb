require 'rails_helper'
require 'importer'
# require 'aws-sdk'

RSpec.describe Importer::CSVImporter do
  # let(:bucket) { Settings.aws.buckets.batch }
  let(:file) { "#{fixture_path}/csv/sample.csv" }
  # let(:csv_file_key) { 'sample.csv' }
  # let(:csv) { Aws::S3::Client.new.get_object(bucket: bucket, key: csv_file_key).body.read }
  # let(:csv_resource) { Aws::S3::Object.new(client: Aws::S3::Client.new, bucket_name: bucket, key: csv_file_key) }
  let(:job_id) { 'e5942432-cfd1-46f0-ba44-67d5fdd2b6e0' }

  context 'batch import with malformed csv file' do
    let(:importer) { described_class.new(csv, csv_resource, job_id) }
    let(:csv_file_key) { 'malformed.csv' }
    # let(:csv) { Aws::S3::Client.new.get_object(bucket: bucket, key: csv_file_key).body.read }
    # let(:csv_resource) { Aws::S3::Object.new(client: Aws::S3::Client.new, bucket_name: bucket, key: csv_file_key) }

    describe '.import_all' do
      it 'creates one batch item with the error' do
        importer.import_all
        expect(BatchItem.first.status).to eq('error')
        expect(BatchItem.count).to eq(1)
      end
    end
  end

  context 'successful batch import' do
    let(:importer) { described_class.new(csv, csv_resource, job_id) }
    let(:collection_factory) { instance_double('CollectionFactory', valid?: true) }
    let(:image_factory) { instance_double('ImageFactory', valid?: true) }
    let(:collection_spy) { instance_spy(collection_factory) }

    before do
      create(:user)
      allow(Importer::Factory::ImageFactory).to receive(:new).with(any_args).and_return(collection_factory)
      allow(collection_factory).to receive(:run)
      allow(image_factory)
    end

    it 'creates new images and collections' do
      importer.import_all
      expect(Importer::Factory::ImageFactory).to have_received(:new)
        .with(hash_excluding(:type), instance_of(Aws::S3::Object))
      expect(collection_factory).to have_received(:run)
    end

    it 'creates batch records' do
      expect { importer.import_all }
        .to change { Batch.count }.by(1)
                                  .and change { BatchItem.count }.by(1)
    end

    it 'sets complete status' do
      importer.import_all
      expect(BatchItem.last.status).to eq('complete')
    end
  end
end
