FactoryBot.define do
  factory :physical_instantiation_resource, class: PhysicalInstantiationResource do
    sequence(:title) { |n| ["Test Physical Instantiation #{n}"] }
    format { "Test format" }
    annotation { ["Test annotation"] }
    date { [ "6/7/1989" ] }
    holding_organization { "American Archive of Public Broadcasting" }
    local_instantiation_identifier { [ "1234" ] }
    location { "Test location" }
    media_type { "Test media_type" }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }

    after(:create) do |work, evaluator|
      work.permission_manager.acl.save
    end

  end

  factory :minimal_physical_instantiation_resource, class: PhysicalInstantiationResource do
    sequence(:title) { |n| ["Minimal Physical Instantiation #{n}"] }
    format { "Minimal format" }
    annotation { ["Minimal annotation"] }
    location { "Minimal location" }
    media_type { "Minimal media_type" }

    after(:create) do |work, evaluator|
      work.permission_manager.acl.save
    end

  end
end
