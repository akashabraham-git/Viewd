

child(@casts => :casts) do
  attributes :id, :name, :pic, :bio
end

node(:pagination) do
  pagy_metadata(@pagy).slice(:count, :page, :items, :pages, :next, :prev)
end