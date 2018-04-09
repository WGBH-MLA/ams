FactoryBot.define do
  factory :series, class: Series do
    sequence(:title) { |n| ["Test Series #{n}"] }
  end
end