module BatchIngestHelpers
  # This is a helper to run a batch ingest from specs. It emulates the behavior
  # of Hyrax::BatchIngest::BatchesController#new and can be run in
  # before(:contxt) hooks within specs, followed by multiple examples that test
  # expectations on the results of the ingest.
  # NOTE: We first tried using capybara to do this through the UI, but found out
  # that you can't do that in before(:context) hooks. You can only do Capybara
  # UI interactions in before(:each) hooks. Since ingests take a long time, we
  # don't want to do them before(:each).
  def run_batch_ingest(ingest_file_path:, ingest_type:, admin_set:, submitter:)
    batch = create(:batch, source_location: ingest_file_path,
                           ingest_type: ingest_type,
                           submitter_email: submitter.email,
                           status: 'received')
    runner = Hyrax::BatchIngest::BatchRunner.new(batch: batch)
    runner.run
    # Return the batch so we can run expectations on it in tests.
    runner.batch
  end
end

RSpec.configure { |c| c.include BatchIngestHelpers }
