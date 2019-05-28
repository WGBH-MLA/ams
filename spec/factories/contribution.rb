FactoryBot.define do
  factory :contribution do
    contributor  { ["Test Contributor"] }
    contributor_role  { "Actor" }
    portrayal  { "Test portrayal" }
    affiliation  { "Test affiliation" }
  end
end
