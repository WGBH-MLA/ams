module AAPB
  module BatchIngest
    # Autoload all the batch ingest object so that you can them all by a
    # simple `require 'aapb/batch_ingest'`
    autoload :BatchReader,                              'aapb/batch_ingest/batch_reader'
    autoload :BatchItemIngester,                         'aapb/batch_ingest/batch_item_ingester'
    autoload :ZippedPBCoreReader,                       'aapb/batch_ingest/zipped_pbcore_reader'
    autoload :ZippedPBCoreDigitalInstantiationReader,   'aapb/batch_ingest/zipped_pbcore_digital_instantiation_reader'
    autoload :PBCoreXMLItemIngester,                    'aapb/batch_ingest/pbcore_xml_item_ingester'
    autoload :CSVReader,                                'aapb/batch_ingest/csv_reader'
    autoload :CSVItemIngester,                          'aapb/batch_ingest/csv_item_ingester'
    autoload :PBCoreXMLMapper,                          'aapb/batch_ingest/pbcore_xml_mapper'
  end
end
