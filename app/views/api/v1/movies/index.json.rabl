
collection @movies
attributes :id, :title, :release_date, :poster_url, :average_rating
node(:genres) { |m| m.genres.pluck(:name) }
node(:pagination) do
  
    pagy_metadata(@pagy)
  
end