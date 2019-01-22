require 'pbcore'

FactoryBot.define do
  factory :pbcore_description_document, class: PBCore::DescriptionDocument, parent: :pbcore_element do
    skip_create

    identifiers { [ build(:pbcore_identifier, :aapb) ] }
    titles { [ PBCore::Title.new(value: Faker::Movie.quote) ] }

    initialize_with { new(attributes) }
  end
end
