FactoryBot.define do
  factory :series, class: Series do
    sequence(:title) { |n| ["Test Series #{n}"] }
    sequence(:description) { |n| ["Description for Series #{n}"] }
  end
end