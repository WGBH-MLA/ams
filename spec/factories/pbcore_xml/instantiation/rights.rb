require 'pbcore'

FactoryBot.define do
  factory :pbcore_instantiation_rights, class: PBCore::Instantiation::Rights, parent: :pbcore_element do
    skip_create

    rights_summary { PBCore::RightsSummary::Summary.new(value: Faker::HitchhikersGuideToTheGalaxy.quote) }
    rights_link { PBCore::RightsSummary::Link.new(value: Faker::Internet.url) }

    initialize_with { new(attributes) }
  end
end