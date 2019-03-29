require 'hyrax/batch_ingest'

module AAPB
  module BatchIngest
    # Base class for all AAPB item ingester objects.
    class BatchItemIngester < Hyrax::BatchIngest::BatchItemIngester
      # Returns the submitter User.
      # @return [User] the batch submitter
      # TODO: Create a patch to move this logic into hyrax-batch_ingest gem?
      #       It Should handle the error case where submitter_email is not
      #       found.
      def submitter
        @submitter ||= User.find_by_email(@batch_item.submitter_email)
      end

      def batch_id
        @batch_id ||= @batch_item.batch.id
      end
    end
  end
end
