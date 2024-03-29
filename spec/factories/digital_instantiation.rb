FactoryBot.define do
  factory :digital_instantiation, class: DigitalInstantiation do
    sequence(:title) { |n| ["Test Digital Instantiation #{n}"] }
    location { "Test location" }
    digital_format { "Test digital_format" }
    media_type { "Test media_type" }
    generations { [ "Proxy"] }
    duration { '1:23:45' }
    file_size { '12354435234' }
    local_instantiation_identifier { ["1234"] }
    digital_instantiation_pbcore_xml { File.open(Rails.root.join('spec/fixtures/sample_instantiation_valid.xml')) }
    trait :aapb_moving_image do
      holding_organization { "American Archive of Public Broadcasting" }
      media_type { "Moving Image" }
    end
    trait :aapb_moving_image_with_essence_track do
      holding_organization { "American Archive of Public Broadcasting" }
      media_type { "Moving Image" }
      ordered_members { [ create(:essence_track)] }
    end
    trait :aapb_sound do
      holding_organization { "American Archive of Public Broadcasting" }
      media_type { "Sound" }
    end
    trait :moving_image do
      media_type { "Moving Image" }
    end
    trait :sound do
      media_type { "Sound" }
    end

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
        # TODO: we shouldn't be saving the DigitalInstantiation after :build.
        # the purpose of :build (instead of :create) is to deliberately NOT
        # save the object.
        work.save
      end
    end
  end
end
