FactoryBot.define do
  factory :physical_instantiation, class: PhysicalInstantiation do
    sequence(:title) { |n| ["Test Physical Instantiation #{n}"] }
    location { "Test location" }
    format { "Test format" }
    media_type { "Test media_type" }
    local_instantiation_identifier { [ "1234" ] }
    holding_organization { "American Archive of Public Broadcasting" }
    date { [ "6/7/1989" ] }
  end
end
