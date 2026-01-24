FactoryBot.define do
  factory :essence_track_resource, class: EssenceTrackResource do
    sequence(:title) { |n| ["Test Essense Track #{n}"] }
    track_type  { "Test Type" }
    track_id  { ["1"] }

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
