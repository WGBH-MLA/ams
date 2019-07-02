module AMS
  class AAPBPBCoreZippedBatchIngestFailureFinder

    def self.find_batches_to_expunge
      Hyrax::BatchIngest::BatchItem.where(:status => ['failed']).map(&:batch_id).uniq
    end

    def self.find_xml_files_to_reingest
      Hyrax::BatchIngest::BatchItem.where(:status => ['expunged']).map(&:id_within_batch).uniq
    end
  end
end
