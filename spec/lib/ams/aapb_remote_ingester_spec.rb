require 'rails_helper'
require 'ams/aapb_remote_ingester'

RSpec.describe AMS::AAPBRemoteIngester do
  subject { described_class.new(host: fake_host, filepath: filepath, ssh_key: fake_ssh_key) }
  let(:fake_host) { 'fake-aapb.org' }
  let(:filepath) { 'path/to/fake_ingest_file.zip' }
  let(:filename) { File.basename(filepath) }
  let(:fake_ssh_key) { 'path/to/fake_ssh_key' }

  describe '#run!' do

    let(:success_status) do
      instance_double(Process::Status).tap do |status|
        allow(status).to receive(:exitstatus).and_return(0)
      end
    end

    let(:fail_status) do
      instance_double(Process::Status).tap do |status|
        allow(status).to receive(:exitstatus).and_return(1)
      end
    end

    before do
      # AMS::AAPBRemoteIngester uses Open3.capture3 to run system commands, so
      # mock it here having all commands return success with no output or
      # errors. These can be overwritten in other testing contexts below.
      allow(Open3).to receive(:capture3).with(subject.commands.fetch(:upload)).and_return(["fake upload output", "", success_status])
      allow(Open3).to receive(:capture3).with(subject.commands.fetch(:unzip)).and_return(["fake unzip output", "", success_status])
      allow(Open3).to receive(:capture3).with(subject.commands.fetch(:ingest)).and_return(["fake ingest output", "", success_status])

      # AMS::AAPBRemoteIngester uses Rails.logger, so mock that here so we can
      # make expectations on what is logged.
      allow(Rails.logger).to receive(:info).with(any_args)
    end

    context 'when none of the system commands fail' do

      before { subject.run! }

      it 'logs the output' do
        expect(Rails.logger).to have_received(:info).with("fake upload output")
        expect(Rails.logger).to have_received(:info).with("fake unzip output")
        expect(Rails.logger).to have_received(:info).with("fake ingest output")
      end

      it 'has all of the output from all the commands' do
        expect(subject.output).to eq ['fake upload output', 'fake unzip output', 'fake ingest output']
      end
    end

    context 'when the upload command fails' do
      before do
        allow(Open3).to receive(:capture3).with(subject.commands.fetch(:upload)).and_return(["", "fake upload error", fail_status])
      end

      it 'raises an UploadFailure error with the error message from stderr' do
        expect { subject.run! }.to raise_error AMS::AAPBRemoteIngester::UploadFailure, "fake upload error"
      end
    end

    context 'when the unzip fails' do
      before do
        allow(Open3).to receive(:capture3).with(subject.commands.fetch(:unzip)).and_return(["", "fake unzip error", fail_status])
      end

      it 'raises an IngestUnzipFailure error' do
        expect { subject.run! }.to raise_error AMS::AAPBRemoteIngester::UnzipFailure, "fake unzip error"
      end
    end

    context 'when the remote command to start the ingest fails' do
      before do
        allow(Open3).to receive(:capture3).with(subject.commands.fetch(:ingest)).and_return(["", "fake ingest error", fail_status])
      end

      it 'raises an IngestFailure error' do
        expect { subject.run! }.to raise_error AMS::AAPBRemoteIngester::IngestFailure, "fake ingest error"
      end
    end
  end
end
