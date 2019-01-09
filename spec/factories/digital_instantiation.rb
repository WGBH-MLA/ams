FactoryBot.define do
  factory :digital_instantiation, class: DigitalInstantiation do
    id { Noid::Rails::Service.new.mint }
    sequence(:title) { |n| ["Test Digital Instantiation #{n}"] }
    location { "Test location" }
    digital_format { "Test digital_format" }
    media_type { "Test media_type" }
    generations { [ "Proxy"] }
    digital_instantiation_pbcore_xml { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/sample_instantiation_valid.xml'), 'text/xml') }
    trait :aapb_moving_image do
      holding_organization { "American Archive of Public Broadcasting" }
      media_type { "Moving Image" }
    end
    trait :aapb_moving_image_with_essence_track do
      holding_organization { "American Archive of Public Broadcasting" }
      media_type { "Moving Image" }
      members { [ create(:essence_track)] }
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
  end
end
