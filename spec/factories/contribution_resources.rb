FactoryBot.define do
  factory :contribution_resource do
    contributor  { ["Test Contributor"] }
    contributor_role  { "Actor" }
    contributor_role_annotation { "Test contributor role annotation" }
    portrayal  { "Test portrayal" }
    affiliation  { "Test affiliation" }
    affiliation_annotation { "Test affiliation annotation" }
    source { "Test source" }
    annotation { "Test annotation" }
    start_time { "00:00:27" }
    end_time { "00:03:30" }
    time_annotation { "Test time annotation" }
  end
end
