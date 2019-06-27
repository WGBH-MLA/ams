module AMS
  class AAPBPBCoreZippedBatchIngestFailureFinder

    def self.find_failures
      Hyrax::BatchIngest::BatchItem.where(:status => 'failed' ).map(&:id_within_batch) - Hyrax::BatchIngest::BatchItem.where(:status => 'completed' ).map(&:id_within_batch)
    end

  end
end
