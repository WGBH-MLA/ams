FactoryBot.define do
  factory :digital_instantiation, class: DigitalInstantiation do
    id { Noid::Rails::Service.new.mint }
    sequence(:title) { |n| ["Test Digital Instantiation #{n}"] }
    location "Test location"
    digital_format "Test digital_format"
    media_type "Test media_type"
    digital_instantiation_pbcore_xml { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/sample_instantiation_valid.xml'), 'text/xml') }
  end
end