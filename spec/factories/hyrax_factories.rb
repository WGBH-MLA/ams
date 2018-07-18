# Specify a list of Hyrax factories to require.
hyrax_factories = [
  'admin_sets',
  'permission_templates',
  'workflows',
  'workflow_actions'
]

# Require the Hyeras factories specified in hyrax_factories
hyrax_factories.each do |hyrax_factory|
  require File.join(Hyrax::Engine.root, 'spec', 'factories', hyrax_factory)
end
