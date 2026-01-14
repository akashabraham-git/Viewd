FactoryBot.define do
  factory :review do
    content { "This was a great movie!" } 
    association :member 
    association :movie
  end
end