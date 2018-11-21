module WGBH
  module BatchIngest
    class ItemIngestor < Hyrax::BatchIngest::BatchItemIngester

      def ingest
        raise "I am not born yet!, one day i will process #{@batch_item.id_within_batch}"
      end
    end
  end
end
