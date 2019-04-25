require_relative 'zip_helpers'

module BatchIngestHelpers
  include ::ZipHelpers

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

  # Creates a zipped batch of PBCore XML.
  # @param [Array<PBCore::DescriptionDocuments] an array of
  #   PBCore::DescriptionDocument instances as returned by
  #   FactoryBot.build(:pbcore_description_document).
  # @return [String] the path to the zipped batch.
  def make_aapb_pbcore_zipped_batch(pbcore_description_documents)
    # Write all of the generated PBCore to individual files in a tmp dir, and
    # zip up the tmp dir for ingesting.
    Dir.mktmpdir do |dir|
      pbcore_description_documents.each do |pbcore_description_document|
        # Look for AAPB ID to use for filename.
        basename = pbcore_description_document.identifiers.detect { |identifier| identifier.source =~ /americanarchive/ }&.value
        # If no AAPB ID, then go random for filename.
        basename ||= SecureRandom.uuid.tr('-', '')
        File.open("#{dir}/#{basename}.xml", 'w') do |f|
          f << pbcore_description_document.to_xml
        end
      end
      zip_to_tmp(dir)
    end
  end
end

RSpec.configure { |c| c.include BatchIngestHelpers }
