FactoryBot.define do
  factory :admin_user do
    sequence(:email) { |n| "admin_#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
  end
end