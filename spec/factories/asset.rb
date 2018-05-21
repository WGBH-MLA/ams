FactoryBot.define do
  factory :asset, class: Asset do
    sequence(:title)         { |n| ["Test Asset #{n}"] }
    sequence(:description)   { |n| ["This is a description of Test Asset #{n}"] }
  end
end