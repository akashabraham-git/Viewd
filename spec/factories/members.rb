FactoryBot.define do
  factory :member do
    bio { "This is my movie bio." }
    country { :india }

    after(:build) do |member|
      member.user ||= build(:user, actable: member)
    end
  end
end