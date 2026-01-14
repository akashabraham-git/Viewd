object @member

attributes :id, :bio, :country

child :user do
  attributes :id, :name, :username, :email
end

node(:statistics) do |member|
  {
    films_count: member.library_entries.watched.count,
    this_year_count: member.library_entries.where('watched_date >= ?', Date.today.beginning_of_year).count
  }
end