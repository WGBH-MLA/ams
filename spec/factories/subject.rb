require 'pbcore'
require 'faker'

FactoryBot.define do
  factory :pbcore_subject, class: PBCore::Subject, parent: :pbcore_element do
    skip_create
    value { Faker::FunnyName.two_word_name }
    initialize_with { new(attributes) }
  end
end
