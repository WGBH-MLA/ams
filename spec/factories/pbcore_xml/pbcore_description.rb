require 'pbcore'

FactoryBot.define do
  factory :pbcore_description, class: PBCore::Description, parent: :pbcore_element do
    skip_create

    value { rand(10000).to_s + Faker::HitchhikersGuideToTheGalaxy.quote }

    initialize_with { new(attributes) }
  end
end
