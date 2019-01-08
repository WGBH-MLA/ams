FactoryBot.define do
  factory :digital_instantiation, class: DigitalInstantiation do
    id { Noid::Rails::Service.new.mint }
    sequence(:title) { |n| ["Test Digital Instantiation #{n}"] }
    location { "Test location" }
    digital_format { "Test digital_format" }
    media_type { "Test media_type" }
    digital_instantiation_pbcore_xml { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/sample_instantiation_valid.xml'), 'text/xml') }
    trait :aapb_moving_image do
      holding_organization { "American Archive of Public Broadcasting" }
      media_type { "Moving Image" }
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
      work.apply_depositor_metadata(evaluator.user.user_key)
      if evaluator.with_admin_data
        attributes = {}
        work.instantiation_admin_data_gid = evaluator.with_instantiation_admin_data if !work.with_instantiation_admin_data.present?
      else
        instantiation_admin_data = create(:instantiation_admin_data)
        work.instantiation_admin_data_gid = instantiation_admin_data.gid
      end
    end

    after(:create) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
      work.save!
    end
  end
end
