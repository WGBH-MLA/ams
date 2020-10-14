require 'pbcore'

FactoryBot.define do
  factory :pbcore_instantiation_rights, class: PBCore::Instantiation::Rights, parent: :pbcore_element do
    skip_create

    summary { PBCore::RightsSummary::Summary.new(value: Faker::Movie.quote) }
    link { PBCore::RightsSummary::Link.new(value: Faker::Internet.url) }

    initialize_with { new(attributes) }
  end
end
