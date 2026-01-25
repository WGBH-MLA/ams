FactoryBot.define do
  factory :essence_track_resource, class: EssenceTrackResource do
    sequence(:title) { |n| ["Test Essense Track #{n}"] }
    track_type  { "Test Type" }
    track_id  { ["1"] }

    # Use Valkyrie persister instead of ActiveRecord-style save! for Ruby 3.0+ compatibility
    to_create { |instance| Hyrax.persister.save(resource: instance) }
  end
end
