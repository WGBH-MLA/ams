FactoryBot.define do
  factory :annotation, class: Annotation do
    ref { Faker::Internet.url }
    value { Faker::Company.bs }
    admin_data { nil }
    annotation_type { nil } # Default to nil unless overridden
    source { nil }
    annotation { nil }
    version { nil }

    # Trait for annotations with a specific annotation_type
    trait :with_annotation_type do
      annotation_type { AnnotationTypesService.new.select_all_options.to_h.values.sample }
    end

    # Trait for annotations without a value
    trait :no_value do
      value { nil }
    end
  end
end
