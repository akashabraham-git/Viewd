ActiveAdmin.register Movie do

  permit_params :title, :tmdb_id, :release_date, :runtime, :status, :language, :origin_country, :poster_url, :synopsis

  scope :all, default: true
  scope :released
  scope :recent

  filter :title
  filter :language, as: :select, collection: -> { Movie.pluck(:language).uniq }
  filter :release_date
  filter :runtime, label: "Duration (Mins)"
  filter :genres, as: :select, collection: -> { Genre.pluck(:name, :id) }
  filter :credits_cast_id, as: :select, collection: -> { Cast.pluck(:name, :id) }, label: "Cast Member"
  
  form do |f|
    f.inputs 'Movie Details' do
      f.input :tmdb_id
      f.input :title
      f.input :origin_country, as: :string
      f.input :status
      f.input :release_date
      f.input :language
      f.input :poster_url
      f.input :synopsis
      f.input :runtime
      
    end
    f.actions
  end

end
