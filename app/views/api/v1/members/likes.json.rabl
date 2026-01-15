collection @liked_movies, root: "liked movies", object_root: false

attributes :id, :title, :poster_url, :release_date

node(:average_rating) { |movie| movie.average_rating }