FactoryBot.define do
  factory :contribution_resource do
    sequence(:contributor)  { |n| ["Test Contributor #{n}"] }
    sequence(:contributor_role)  { |n| "Actor #{n}" }
    sequence(:contributor_role_annotation) { |n| "Test contributor role annotation #{n}" }
    sequence(:portrayal)  { |n| "Test portrayal #{n}" }
    sequence(:affiliation)  { |n| "Test affiliation #{n}" }
    sequence(:affiliation_annotation) { |n| "Test affiliation annotation #{n}" }
    sequence(:source) { |n| "Test source #{n}" }
    sequence(:annotation) { |n| "Test annotation #{n}" }
    sequence(:start_time) { |n| rand(n.to_f..(n+10).to_f).round(3).to_s }
    sequence(:end_time) { |n| (start_time.to_f + rand(1.0..10.0)).round(3).to_s }
    sequence(:time_annotation) { |n| "Test time annotation #{n}" }
  end
end
