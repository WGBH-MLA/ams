FactoryBot.define do
  factory :asset, class: Asset do

    transient do
      user { create(:user) }
    end

    sequence(:title)         { |n| ["Test Asset #{n}"] }
    sequence(:description)   { |n| ["This is a description of Test Asset #{n}"] }

    trait :public do
      visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    end

    after(:create) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
      work.save!
    end
  end
end