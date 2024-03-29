FactoryBot.define do
  factory :asset do
    sequence(:title)         { |n| ["Test Asset #{n}"] }
    sequence(:description)   { |n| ["This is a description of Test Asset #{n}"] }
    sequence(:bulkrax_identifier) { |n| "1-Assets-#{n}-#{n}"}
    annotation  { ['Sample Annotation'] }
    asset_types  { ['Clip','Promo'] }
    audience_level  {  ['PG14'] }
    audience_rating  { ['4.3'] }
    broadcast_date  { ["2010","2015-01","1987-10-31"] }
    clip_description  { ['Test clip_description'] }
    clip_title  { ['Test clip_title'] }
    copyright_date  { ["2010","2015-01","1987-10-31"] }
    created_date  { ["2010","2015-01","1987-10-31"] }
    date  { ["2010","2015-01","1987-10-31"] }
    eidr_id  { ['eidr_id-001'] }
    episode_description  { ['Test episode_description'] }
    episode_number  { ['S01E2'] }
    episode_title  { ['Test episode_title'] }
    genre  { ['Drama','Debate'] }
    local_identifier  { ['WGBH-11'] }
    pbs_nola_code  { ['PBS-WGBH-11'] }
    producing_organization  { ['Test producing_organization'] }
    program_description  { ['Test program_description'] }
    program_title  { ['Test program_title'] }
    promo_description  { ['Test promo_description'] }
    promo_title  { ['Test promo_title'] }
    raw_footage_description  { ['Test raw_footage_description'] }
    raw_footage_title  { ['Test raw_footage_title'] }
    rights_link  { ['http://www.google.com'] }
    rights_summary  { ['Sample rights_summary'] }
    segment_description  { ['Test segment_description'] }
    segment_title  { ['Test segment_title'] }
    spatial_coverage  { ['TEST spatial_coverage'] }
    subject  { ['Test subject'] }
    temporal_coverage  { ['Test temporal_coverage'] }
    topics  { ['Animals','Business'] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }

    transient do
      user { create(:user) }
      # Pass in AdminData.gid or it will create one for you!
      with_admin_data { false }
      # Pass in an AdminSet instance, or an admin set id, for example
      # create(:asset, admin_set: create(:admin_set))
      admin_set { false }
      needs_update { false }

      # This is where you would set the Asset's PhysicalInstantiations,
      # DigitalINstantiations, and/or Contributions
      ordered_members { [] }
    end

    trait :public do
      visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    end

    trait :with_physical_instantiation do
      ordered_members { [ create(:physical_instantiation) ] }
    end

    trait :with_two_physical_instantiations do
      ordered_members { [
        create(:physical_instantiation),
        create(:minimal_physical_instantiation)
      ] }
    end

    trait :with_digital_instantiation do
      ordered_members { [ create(:digital_instantiation) ] }
    end

    trait :with_digital_instantiation_and_essence_track do
      ordered_members { [ create(:digital_instantiation, :aapb_moving_image_with_essence_track) ] }
    end

    trait :with_two_digital_instantiations_and_essence_tracks do
      ordered_members { [
        create(:digital_instantiation, :aapb_moving_image_with_essence_track),
        create(:digital_instantiation, :aapb_moving_image_with_essence_track)
      ] }
    end

    trait :with_physical_digital_and_essence_track do
      ordered_members { [
        create(:physical_instantiation),
        create(:digital_instantiation, :aapb_moving_image_with_essence_track),
      ] }
    end

    trait :family do
      ordered_members do
        [
          rand(2..4).times.map do
            create(:digital_instantiation,
              ordered_members: rand(2..4).times.map do
                create(:essence_track)
              end
            )
          end,
          rand(1..2).times.map do
            create(:physical_instantiation,
              ordered_members: rand(2..4).times.map do
                create(:essence_track)
              end
            )
          end,
          rand(2..4).times.map { create(:contribution) }
        ].flatten
      end
    end

    before(:create) do |work, evaluator|
      if evaluator.admin_set
        work.admin_set_id = evaluator.admin_set.id
      end
    end

    after(:build) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
      if evaluator.with_admin_data
        attributes = {}
        work.admin_data_gid = evaluator.with_admin_data if !work.admin_data_gid.present?
      else
        if evaluator.needs_update
          admin_data = create(:admin_data, :needs_update)
        else
          admin_data = create(:admin_data)
        end

        work.admin_data_gid = admin_data.gid
      end

      if evaluator.ordered_members
        evaluator.ordered_members.each do |ordered_member|
          work.ordered_members << ordered_member
        end
      end
    end

    after(:create) do |work, evaluator|
      # TODO: don't think this is needed, since it's happening in after(:build)
      work.apply_depositor_metadata(evaluator.user.user_key)
      work.save!
    end
  end
end
