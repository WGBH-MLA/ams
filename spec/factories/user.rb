FactoryBot.define do
  factory :user, class: User do
    sequence(:email) { |_n| "email-#{srand}@test.com" }
    password 'a password'
    password_confirmation 'a password'
    guest true
  end
end
