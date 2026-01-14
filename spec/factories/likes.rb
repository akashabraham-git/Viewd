FactoryBot.define do
  factory :like do
    association :member

    trait :for_movie do
      association :likeable, factory: :movie
    end

    trait :for_review do
      association :likeable, factory: :review
    end
  end
end