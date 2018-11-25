FactoryBot.define do
  factory :physical_instantiation, class: PhysicalInstantiation do
    id { Noid::Rails::Service.new.mint }
    sequence(:title) { |n| ["Test Physical Instantiation #{n}"] }
    location { "Test location" }
    format { "Test format" }
    media_type { "Test media_type" }
  end
end
