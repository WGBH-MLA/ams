# Specify a list of Hyrax factories to require.
hyrax_factories = [
  'admin_sets',
  'permission_templates',
  'permission_template_accesses',
  'collections',
  'collections_factory',
  'collection_types',
  'collection_type_participants',
  'collection_branding_infos',
  'object_id',
  'workflows',
  'workflow_actions'
]

# Require the Hyrax factories specified in hyrax_factories
hyrax_factories.each do |hyrax_factory|
  require File.join(Hyrax::Engine.root, 'spec', 'factories', hyrax_factory)
end
