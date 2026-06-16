FactoryBot.define do
  factory :contribution_resource do
    contributor  { ["Test Contributor"] }
    contributor_role  { "Actor" }
    portrayal  { "Test portrayal" }
    affiliation  { "Test affiliation" }
    annotation  { "Test annotation" }
  end
end
