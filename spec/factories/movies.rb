FactoryBot.define do
  factory :movie do
    sequence(:title) { |n| "Movie Title #{n}" }
    synopsis { "This is a detailed synopsis that is at least ten characters long." }
    release_date { Date.today }
    status { :released }
    poster_url { "https://example.com/poster.jpg" }
  end
end