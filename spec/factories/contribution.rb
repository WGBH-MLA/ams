FactoryBot.define do
  factory :contribution do
    id { Noid::Rails::Service.new.mint }
    sequence(:title) { |n| ["Test Admin Set #{n}"] }
    contributor ["Test Contributor"]
    contributor_role "Actor"
    portrayal "Test portrayal"
    affiliation "Test affiliation"
  end
end