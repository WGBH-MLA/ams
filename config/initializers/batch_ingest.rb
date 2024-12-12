# These requires are needed for concurrent jobs; relying on autoloading resutls
# in concurrent jobs not having the necessary objects loaded when running.
require 'aapb/batch_ingest/pbcore_xml_item_ingester'
require 'aapb/batch_ingest/zipped_pbcore_reader'
require 'aapb/batch_ingest/zipped_pbcore_digital_instantiation_reader'
require 'aapb/batch_ingest/pbcore_xml_instantiation_reset'

Hyrax::BatchIngest::BatchItemProcessingJob.queue_as :ingest
