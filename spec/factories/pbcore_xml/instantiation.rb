require 'pbcore'

FactoryBot.define do
  factory :pbcore_instantiation, class: PBCore::Instantiation, parent: :pbcore_element do
    skip_create

    identifiers             { [ build(:pbcore_instantiation_identifier, :ams),
                                build(:pbcore_instantiation_identifier) ] }
    dates                   { [ build(:pbcore_instantiation_date), build(:pbcore_instantiation_date, :digitized) ] }
    dimensions              { [ build(:pbcore_instantiation_dimensions) ] }
    standard                { build(:pbcore_instantiation_standard) }
    location                { build(:pbcore_instantiation_location) }
    media_type              { build(:pbcore_instantiation_media_type) }
    generations             { [ build(:pbcore_instantiation_generations) ] }
    time_start             { build(:pbcore_instantiation_time_start) }
    duration                { build(:pbcore_instantiation_duration) }
    colors                  { build(:pbcore_instantiation_colors) }
    rights                  { [ build(:pbcore_instantiation_rights) ] }
    tracks                  { build(:pbcore_instantiation_tracks) }
    channel_configuration   { build(:pbcore_instantiation_channel_configuration) }
    alternative_modes       { build(:pbcore_instantiation_alternative_modes) }

    initialize_with { new(attributes) }

    trait :digital do
      digital   { build(:pbcore_instantiation_digital) }
    end

    trait :physical do
      physical { build(:pbcore_instantiation_physical) }
    end

    transient do
      aapb_holding { true }
      on_lto { true }
      on_disk { true }
    end

    after(:build) do |inst, evaluator|
      if evaluator.aapb_holding
        inst.annotations << build(:pbcore_instantiation_annotation, type: "Organization", value: "American Archive of Public Broadcasting")
      end

      if evaluator.on_lto
        # If the value is simply TRUE (the default), then convert it to a random string.
        val = evaluator.on_lto == true ? SecureRandom.hex[0..10] : evaluator.on_lto.to_s
        inst.annotations << build(:pbcore_instantiation_annotation, type: "AAPB Preservation LTO", value: val)
      end

      if evaluator.on_disk
        # If the value is simply TRUE (the default), then convert it to a random string.
        val = evaluator.on_disk == true ? SecureRandom.hex[0..10] : evaluator.on_disk.to_s
        inst.annotations << build(:pbcore_instantiation_annotation, type: "AAPB Preservation Disk", value: val)
      end
    end
  end
end
