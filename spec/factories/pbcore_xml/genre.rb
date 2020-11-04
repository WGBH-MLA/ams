require 'pbcore'

FactoryBot.define do
  factory :pbcore_genre, class: PBCore::Genre, parent: :pbcore_element do
    skip_create
    value { ['Documentary', 'Game Show', 'Performance in a Studio',
             'Performance for a Live Audience', 'Magazine', 'Promo'].sample }
    annotation { "genre" }
    source { "AAPB Format Genre" }
    initialize_with { new(attributes) }

    trait :topic do
      source { "AAPB Format Topic" }
      value { Faker::Book.genre }
      annotation { "topic" }
    end
  end
end
