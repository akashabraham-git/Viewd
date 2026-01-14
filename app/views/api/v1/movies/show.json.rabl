object @movie
attributes :id, :title, :synopsis, :poster_url, :release_date, :origin_country, :runtime, :language, :average_rating

child(@movie.credits.limit(5) => :credits) do
  attributes :character, :job
  child :cast do
    attributes :id, :name, :pic
  end
end