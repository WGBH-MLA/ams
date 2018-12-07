# Specify a list of factories from hyrax-batch_ingest gem to require.
batch_ingest_factories = [
  'batch',
  'batch_item'
]

# Require the factories from hyrax-batch_ingest gem.
batch_ingest_factories.each do |factory|
  require File.join(Hyrax::BatchIngest::Engine.root, 'spec', 'factories', factory)
end
