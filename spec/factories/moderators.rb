FactoryBot.define do
  factory :moderator do
    sequence(:employee_number) { |n| "MOD-#{1000 + n}" }
    department { "Compliance" }

    after(:build) do |moderator|
      moderator.user ||= build(:user, actable: moderator, actable_type: "Moderator")
    end
  end
end