module WGBH
  module BatchIngest
    class BatchReader < Hyrax::BatchIngest::BatchReader
      # Add any custom code here.
      #

      def delete_manifest
        # I will do nothing of the sort (overrides BatchScanner method we dont use)!
        true 
      end
    end
  end
end