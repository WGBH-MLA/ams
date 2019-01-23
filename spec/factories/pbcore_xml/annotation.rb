require 'pbcore'
require 'faker'

FactoryBot.define do
  factory :pbcore_annotation, class: PBCore::Annotation, parent: :pbcore_element do
    skip_create
    value { Faker::FamousLastWords.last_words }
    initialize_with { new(attributes) }
  end
end
