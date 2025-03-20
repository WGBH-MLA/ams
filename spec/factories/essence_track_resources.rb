FactoryBot.define do
  factory :essence_track_resource, class: EssenceTrackResource do
    sequence(:title) { |n| ["Test Essense Track #{n}"] }
    track_type  { "Test Type" }
    track_id  { ["1"] }
  end
end
