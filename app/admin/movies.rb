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

  index do
    selectable_column
    id_column
    column :poster do |movie|
      image_tag movie.poster_url, width: '50' if movie.poster_url.present?
    end
    column :title
    column :status do |movie|
      status_tag movie.status
    end
    column :release_date
    column :language
    column "Average Rating" do |movie|
      avg = movie.average_rating
      avg ? "#{avg.to_f.round(1)} / 5" : "No ratings"
    end
    actions
  end

  show title: :title do
    columns do
      column span: 2 do
        attributes_table do
          row :id
          row :title
          row :synopsis
          row :release_date
          row :runtime do |m| "#{m.runtime} mins" end
          row :language
          row :origin_country
          row :status
          row :tmdb_id
          row "Genres" do |m|
            m.genres.map(&:name).join(", ")
          end
        end

        panel "Cast & Credits" do
          table_for movie.credits do
            column "Actor" do |credit| 
              link_to credit.cast.name, admin_cast_path(credit.cast) 
            end
            column :character
            column :job
          end
        end
      end

      column do
        panel "Movie Poster" do
          image_tag movie.poster_url, width: '100%' if movie.poster_url.present?
        end

        panel "Engagement Stats" do
          attributes_table_for movie do
            row("Total Reviews") { movie.reviews.count }
            row("Total Likes") { movie.likes.count }
            row("Average Rating") { movie.ratings.average(:rating).to_f.round(2) }
          end
        end
      end
    end
  end

  batch_action :mark_as_released do |ids|
    batch_action_collection.find(ids).each do |movie|
      movie.update!(status: :released, release_date: Date.today)
    end
    redirect_to collection_path, notice: "Selected movies marked as released!"
  end

  action_item :view_reviews, only: :show do
    link_to "View Reviews", admin_reviews_path("q[movie_id_eq]" => movie.id)
  end
end
