FactoryBot.define do
  factory :asset do
    id { Noid::Rails::Service.new.mint }
    sequence(:title)         { |n| ["Test Asset #{n}"] }
    sequence(:description)   { |n| ["This is a description of Test Asset #{n}"] }
    asset_types ['Clip','Promo']
    genre ['Drama','Debate']
    broadcast_date ['07/17/2017']
    created_date ['07/05/2017']
    copyright_date ['07/07/2017']
    date ['07/04/2017']
    episode_number ['S01E2']
    spatial_coverage ['TEST spatial_coverage']
    temporal_coverage ['Test temporal_coverage']
    audience_level  ['PG14']
    audience_rating ['4.3']
    annotation ['Sample Annotation']
    rights_summary ['Sample rights_summary']
    rights_link ['http://www.google.com']
    local_identifier ['WGBH-11']
    pbs_nola_code ['PBS-WGBH-11']
    eidr_id ['eidr_id-001']
    topics ['Animals','Business']
    subject ['Test subject']
    program_title ['Test program_title']
    episode_title ['Test episode_title']
    segment_title ['Test segment_title']
    raw_footage_title ['Test raw_footage_title']
    promo_title ['Test promo_title']
    clip_title ['Test clip_title']
    program_description ['Test program_description']
    episode_description ['Test episode_description']
    segment_description ['Test segment_description']
    raw_footage_description ['Test raw_footage_description']
    promo_description ['Test promo_description']
    clip_description ['Test clip_description']



    visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC


    transient do
      user { create(:user) }
      # Pass in AdminData.gid or it will create one for you!
      with_admin_data false
      # Pass in an AdminSet instance, or an admin set id, for example
      # create(:asset, admin_set: create(:admin_set))
      admin_set false
    end

    trait :public do
      visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
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
        admin_data = create(:admin_data)
        work.admin_data_gid = admin_data.gid
      end
    end

    after(:create) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
      work.save!
    end
  end
end
