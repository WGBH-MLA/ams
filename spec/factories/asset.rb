FactoryBot.define do
  factory :asset, class: Asset do
    sequence(:title) { |n| ["Test Asset #{n}"] }
    sequence(:description) { |n| ["Test Description of Asset #{n}"] }
  end
end