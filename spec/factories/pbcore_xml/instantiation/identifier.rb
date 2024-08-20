require 'pbcore'
require 'ams/identifier_service'

FactoryBot.define do
  factory :pbcore_instantiation_identifier, class: PBCore::Instantiation::Identifier, parent: :pbcore_element do
    skip_create

    source { Faker::Company.name }
    value { Faker::IDNumber.valid }

    trait :ams do
      source { "ams" }
      value { ::AMS::IdentifierService.mint }
    end

    initialize_with { new(attributes) }
  end
end