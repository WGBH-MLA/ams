require 'pbcore'

FactoryBot.define do
  factory :pbcore_instantiation_essence_track_time_start, class: PBCore::Instantiation::EssenceTrack::TimeStart, parent: :pbcore_element do
    skip_create

    value { Time.now.strftime( "%H:%M:%S") + ":00" }

    initialize_with { new(attributes) }
  end
end