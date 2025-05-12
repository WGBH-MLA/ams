FactoryBot.define do
  factory :annotation, class: Annotation do
    ref { Faker::Internet.url }
    value { Faker::Company.bs }
    admin_data { nil }
    annotation_type { nil } # Set to nil by default
    source { nil }
    annotation { nil }
    version { nil }

    trait :with_annotation_type do
      annotation_type { AnnotationTypesService.new.select_all_options.to_h.values.sample }
    end
  end
end
