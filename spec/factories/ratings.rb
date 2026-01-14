FactoryBot.define do
  factory :rating do
    rating { 5 }          
    association :member   
    association :movie
  end
end