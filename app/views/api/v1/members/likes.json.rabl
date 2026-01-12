collection @liked_movies, root: "movies", object_root: false
attributes :id, :title, :poster_url, :release_date

# app/views/api/v1/members/library.rabl
collection @entries, root: "library", object_root: false

node(:id) { |entry| entry.id }
node(:watched_date) { |entry| entry.watched_date }
node(:movie) do |entry|
  {
    id: entry.movie.id,
    title: entry.movie.title,
    poster_url: entry.movie.poster_url,
    release_date: entry.movie.release_date
  }
end