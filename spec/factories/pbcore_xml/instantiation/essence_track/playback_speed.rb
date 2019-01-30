require 'pbcore'

FactoryBot.define do
  factory :pbcore_instantiation_essence_track_playback_speed, class: PBCore::Instantiation::EssenceTrack::PlaybackSpeed, parent: :pbcore_element do
    skip_create

    value { rand(1..50).to_s }
    units_of_measure { Faker::Hacker.abbreviation }

    initialize_with { new(attributes) }

    trait :inches_per_second do
      units_of_measure { 'inches per second' }
    end

    trait :frames_per_second do
      units_of_measure { 'frames per second' }
    end
  end
end