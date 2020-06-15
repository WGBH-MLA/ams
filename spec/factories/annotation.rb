FactoryBot.define do
  factory :annotation, class: Annotation do
    ref { Faker::Internet.url }
    value { Faker::Company.bs }
    admin_data { nil }
    annotation_type { AnnotationTypesService.new.select_all_options.to_h.values.sample }
    source { nil }
    annotation { nil }
    version { nil }

    trait :no_value do
      value { nil }
    end
  end
end
