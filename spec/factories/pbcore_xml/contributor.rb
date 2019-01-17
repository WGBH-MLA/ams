require 'pbcore'
require 'faker'

FactoryBot.define do
  factory :pbcore_contributor, class: PBCore::Contributor, parent: :pbcore_element do
    skip_create

    contributor { PBCore::Contributor::Contributor.new(value: Faker::FunnyName.two_word_name) }
    role { PBCore::Contributor::Role.new(value: Faker::Job.title)  }

    initialize_with { new(attributes) }
  end
end
