FactoryBot.define do
  factory :contribution_resource do
    contributor  { ["Test Contributor"] }
    contributor_role  { "Actor" }
    portrayal  { "Test portrayal" }
    affiliation  { "Test affiliation" }

    # Use Valkyrie persister instead of ActiveRecord-style save! for Ruby 3.0+ compatibility
    to_create { |instance| Hyrax.persister.save(resource: instance) }
  end
end
