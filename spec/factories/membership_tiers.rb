FactoryBot.define do
  factory :membership_tier do
    sequence(:name) { |n| "Tier #{n}" }
    price { 10 }
    has_ads { false }
    can_view_stats { true }
    country { :usa } 
    
    trait :free do
      name { "Free" }
      price { 0 }
      has_ads { true }
      can_view_stats { false }
      country { :unknown }
    end

    trait :pro do
      name { "Pro" }
      price { 10 }
    end

    trait :patron do
      name { "Patron" }
      price { 20 }
    end
  end
end