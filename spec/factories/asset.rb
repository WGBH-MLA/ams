FactoryBot.define do
  factory :asset do
    id { Noid::Rails::Service.new.mint }
    sequence(:title)         { |n| ["Test Asset #{n}"] }
    sequence(:description)   { |n| ["This is a description of Test Asset #{n}"] }
    visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC


    transient do
      user { create(:user) }
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
      if evaluator.with_admin_data
        attributes = {}
        work.admin_data_gid = evaluator.with_admin_data if !work.admin_data_gid.present?
      end
    end

    after(:create) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
      work.save!
    end
  end
end
