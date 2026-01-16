FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "user_#{n}" }
    sequence(:email) { |n| "test_#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    association :actable, factory: :member
    actable_type { "Member" }

    trait :as_member do
      association :actable, factory: :member
      actable_type { "Member" }
    end

    trait :as_moderator do
      association :actable, factory: :moderator
      actable_type { "Moderator" }
    end
  end
end