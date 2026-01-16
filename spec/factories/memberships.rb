FactoryBot.define do
  factory :membership do
    association :member
    association :membership_tier
    status { :active }
  end
end