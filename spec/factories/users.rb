FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "testuser#{n}" }
    name { "Test User" }
    sequence(:email) { |n| "test#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    actable_type { "Member" }
    association :actable, factory: :member
  end
end