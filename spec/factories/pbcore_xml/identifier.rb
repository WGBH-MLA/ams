require 'pbcore'

FactoryBot.define do
  factory :pbcore_identifier, class: PBCore::Identifier, parent: :pbcore_element do
    skip_create

    trait :aapb do
      source { "http://americanarchiveinventory.org" }
      value { "cpb-blah-blah-blah" }
    end

    initialize_with { new(attributes) }
  end
end
