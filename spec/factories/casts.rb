FactoryBot.define do
  factory :cast do
    sequence(:name) { |n| "Person #{n}" }
    sequence(:tmdb_id) { |n| n + 1000 }
  end
end