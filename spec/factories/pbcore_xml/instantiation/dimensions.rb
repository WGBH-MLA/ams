require 'pbcore'

FactoryBot.define do
  factory :pbcore_instantiation_dimensions, class: PBCore::Instantiation::Dimensions, parent: :pbcore_element do
    skip_create

    units_of_measure { Faker::Measurement.height(amount: "all") }
    value { Faker::Number.number(digits: 1).to_s + 'x' + Faker::Number.number(digits: 1).to_s }

    initialize_with { new(attributes) }
  end
end
