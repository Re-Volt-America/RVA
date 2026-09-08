FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "Racer#{n}" }
    sequence(:email) { |n| "racer#{n}@example.com" }
    password { 'Password123!' }
    password_confirmation { 'Password123!' }
    confirmed_at { Time.current }
  end
end
