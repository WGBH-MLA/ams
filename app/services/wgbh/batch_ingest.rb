module WGBH
  module BatchIngest
    # Autoload all the batch ingest object so that you can them all by a
    # simple `require 'wgbh/batch_ingest'`
    autoload :ZippedPBCoreReader,    'wgbh/batch_ingest/zipped_pbcore_reader'
    autoload :PBCoreXMLItemIngester, 'wgbh/batch_ingest/pbcore_xml_item_ingester'
  end
end
