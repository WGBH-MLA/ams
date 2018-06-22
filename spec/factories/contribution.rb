FactoryBot.define do
  factory :contribution do
    sequence(:title) { |n| ["Test Admin Set #{n}"] }
    contributor ["Test Contributor"]
    contributor_role ["Actor"]
    portrayal ["Test portrayal"]
  end
end