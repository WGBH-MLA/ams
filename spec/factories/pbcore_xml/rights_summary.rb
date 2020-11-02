require 'pbcore'

FactoryBot.define do
  factory :pbcore_rights_summary, class: PBCore::RightsSummary, parent: :pbcore_element do
    skip_create

    trait :summary do
      summary { PBCore::RightsSummary::Summary.new(value: Faker::GreekPhilosophers.quote) }
    end

    trait :link do
      link { PBCore::RightsSummary::Link.new(value: Faker::Internet.url )}
    end

    initialize_with { new(attributes) }
  end
end
