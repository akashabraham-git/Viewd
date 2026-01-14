child(@movies => :movies) do
  attributes :id, :title, :release_date, :poster_url, :average_rating
  node(:genres) { |m| m.genres.pluck(:name) }
end

node(:pagination) do
  pagy_metadata(@pagy).slice(:count, :page, :items, :pages, :next, :prev)
end