FactoryBot.define do
  factory :credit do
    association :movie
    association :cast
    job { "Actor" }
    character { "Lead Role" }
  end
end