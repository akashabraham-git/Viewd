collection @entries, root: "watchlist", object_root: false

node(:id) { |entry| entry.id }
node(:updated_at) { |entry| entry.updated_at }
node(:movie) do |entry|
  {
    id: entry.movie.id,
    title: entry.movie.title,
    poster_url: entry.movie.poster_url,
    release_date: entry.movie.release_date
  }
end