object @user => :user

attributes :id, :name, :username, :email

node(:actable_type) { |user| user.actable_type }

node(:profile) do |user|
  if user.actable_type == 'Member' && user.actable
    {
      bio: user.actable.bio,
      profile_picture_url: if user.actable.profile_picture.attached?
        Rails.application.routes.url_helpers.rails_blob_url(user.actable.profile_picture, only_path: true)
      else
        nil
      end
    }
  else
    nil
  end
end

node(:statistics) do
  if @user.actable_type == 'Member'
    {
      films_count: @films_count,
      this_year_count: @this_year_count
    }
  else
    nil
  end
end

node(:favorite_movies) do
  if @user.actable_type == 'Member' && @favorite_movies
    @favorite_movies.map do |movie|
      {
        id: movie.id,
        title: movie.title,
        poster_url: movie.poster_url,
        release_date: movie.release_date
      }
    end
  else
    []
  end
end

node(:watchlist) do
  if @user.actable_type == 'Member' && @watchlist
    @watchlist.map do |entry|
      {
        id: entry.id,
        movie: {
          id: entry.movie.id,
          title: entry.movie.title,
          poster_url: entry.movie.poster_url
        },
        updated_at: entry.updated_at
      }
    end
  else
    []
  end
end

node(:recent_activity) do
  if @user.actable_type == 'Member' && @recent_activity
    @recent_activity.map do |entry|
      {
        id: entry.id,
        movie: {
          id: entry.movie.id,
          title: entry.movie.title,
          poster_url: entry.movie.poster_url
        },
        watched_date: entry.watched_date
      }
    end
  else
    []
  end
end

node(:top_reviews) do
  if @user.actable_type == 'Member' && @top_reviews
    @top_reviews.map do |review|
      {
        id: review.id,
        content: review.content,
        likes_count: review.likes.size,
        movie: {
          id: review.movie.id,
          title: review.movie.title,
          poster_url: review.movie.poster_url
        },
        created_at: review.created_at
      }
    end
  else
    []
  end
end
