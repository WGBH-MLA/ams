FactoryBot.define do
  factory :role do
    sequence(:name) {|n| "Role_#{n}" }
  end
end
