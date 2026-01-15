object @genre

attributes :id, :name

child @movies => :movies do
  attributes :id, :title, :release_date
end
