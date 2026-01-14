FactoryBot.define do
  factory :connection do
    association :follower, factory: :member
    association :following, factory: :member
  end
end