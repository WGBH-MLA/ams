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

    transient do
      # Pass in InstantiationAdminData.gid or it will create one for you!
      with_instantiation_admin_data { false }
    end

    after(:build) do |work, evaluator|
      if evaluator.with_instantiation_admin_data
        attributes = {}
        work.instantiation_admin_data_gid = evaluator.with_instantiation_admin_data if !work.instantiation_admin_data_gid.present?
      else
        instantiation_admin_data = create(:instantiation_admin_data)
        work.instantiation_admin_data_gid = instantiation_admin_data.gid
        # Save using Valkyrie persister pattern for Ruby 3.2 compatibility
        Hyrax.persister.save(resource: work)
      end
    end
  end

  factory :minimal_physical_instantiation_resource, class: PhysicalInstantiationResource do
    sequence(:title) { |n| ["Minimal Physical Instantiation #{n}"] }
    format { "Minimal format" }
    annotation { ["Minimal annotation"] }
    location { "Minimal location" }
    media_type { "Minimal media_type" }

    transient do
      # Pass in InstantiationAdminData.gid or it will create one for you!
      with_instantiation_admin_data { false }
    end

    after(:build) do |work, evaluator|
      if evaluator.with_instantiation_admin_data
        attributes = {}
        work.instantiation_admin_data_gid = evaluator.with_instantiation_admin_data if !work.instantiation_admin_data_gid.present?
      else
        instantiation_admin_data = create(:instantiation_admin_data)
        work.instantiation_admin_data_gid = instantiation_admin_data.gid
        # Save using Valkyrie persister pattern for Ruby 3.2 compatibility
        Hyrax.persister.save(resource: work)
      end
    end
  end
end
