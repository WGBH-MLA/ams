FactoryBot.define do
  factory :user, class: User do
    sequence(:email) { |_n| "email-#{srand}@test.com" }
    password 'a password'
    password_confirmation 'a password'
    guest true
  end

  factory :admin_user, class: User do
    sequence(:email) { 'wgbh_admin@wgbh-mla.org' }
    password 'a password'
    password_confirmation 'a password'
    guest true
  end
end
