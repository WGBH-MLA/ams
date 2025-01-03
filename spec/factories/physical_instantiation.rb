FactoryBot.define do
  factory :physical_instantiation, class: PhysicalInstantiation do
    sequence(:title) { |n| ["Test Physical Instantiation #{n}"] }
    format { "Test format" }
    annotation { ["Test annotation"] }
    date { [ "6/7/1989" ] }
    holding_organization { "American Archive of Public Broadcasting" }
    local_instantiation_identifier { [ "1234" ] }
    location { "Test location" }
    media_type { "Test media_type" }

    trait :without_media_type do
      media_type { nil }
    end
  end

  factory :minimal_physical_instantiation, class: PhysicalInstantiation do
    sequence(:title) { |n| ["Minimal Physical Instantiation #{n}"] }
    format { "Minimal format" }
    annotation { ["Minimal annotation"] }
    location { "Minimal location" }
    media_type { "Minimal media_type" }
  end

    trait :without_media_type do
      media_type { nil }
    end
  end
end
