FactoryBot.define do
  factory :contribution_resource do
    contributor  { ["Test Contributor"] }
    contributor_role  { "Actor" }
    portrayal  { "Test portrayal" }
    affiliation  { "Test affiliation" }

    # Use Valkyrie persister instead of ActiveRecord-style save! for Ruby 3.0+ compatibility
    to_create do |instance|
      result = Hyrax.persister.save(resource: instance)
      # Update the instance with the persisted ID
      instance.id = result.id
      instance.new_record = false if instance.respond_to?(:new_record=)
      result
    end
  end
end
