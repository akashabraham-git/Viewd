FactoryBot.define do
  factory :movie do
    title { "Inception" }
    release_date { "2010-07-16" }
    status { :released } 
  end
end