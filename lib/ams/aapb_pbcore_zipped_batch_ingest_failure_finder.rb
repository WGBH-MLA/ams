module AMS
  class AAPBPBCoreZippedBatchIngestFailureFinder

    def self.find_failures
      successful_batch_items = Hyrax::BatchIngest::BatchItem.where(:status => 'completed' ).map(&:id)
      failed_batched_items = Hyrax::BatchIngest::BatchItem.where(:status => 'failed' ).map(&:id) - successful_batch_items
    end

  end
end
