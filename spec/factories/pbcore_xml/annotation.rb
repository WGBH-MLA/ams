require 'pbcore'
require 'faker'

FactoryBot.define do
  factory :pbcore_annotation, class: PBCore::Annotation, parent: :pbcore_element do
    skip_create
    type { AnnotationTypesService.new.select_all_options.to_h.values.sample }
    ref { Faker::Internet.url }
    value { Faker::Quote.famous_last_words }
    initialize_with { new(attributes) }
  end
end
