module AAPB
  module BatchIngest
    # Autoload all the batch ingest object so that you can them all by a
    # simple `require 'AAPB/batch_ingest'`
    autoload :ZippedPBCoreReader,    'aapb/batch_ingest/zipped_pbcore_reader'
    autoload :PBCoreXMLItemIngester, 'aapb/batch_ingest/pbcore_xml_item_ingester'
  end
end
