FactoryBot.define do
  factory :movie do
    sequence(:title) { |n| "Movie Title #{n}" }
    synopsis { "This is a detailed synopsis that is at least ten characters long." }
    release_date { Date.today }
    status { :released }
  end
end