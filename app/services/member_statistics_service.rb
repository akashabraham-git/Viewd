class MemberStatisticsService
  def initialize(member, year = nil)
    @member = member
    @year = year
    @watched_entries = fetch_watched_entries
  end

  def call
    if @year
      by_year_statistics
    else
      all_time_statistics
    end
  end

  private

  def fetch_watched_entries
    entries = @member.library_entries
                     .where.not(watched_date: nil)
                     .includes(:movie)

    if @year
      year_start = Date.new(@year, 1, 1)
      year_end = Date.new(@year, 12, 31)
      return entries.where(watched_date: year_start..year_end)
    end

    entries
  end

  def all_time_statistics
    {
      total_films: @watched_entries.count,
      total_hours: calculate_total_hours,
      average_rating: calculate_average_rating,
      release_year_distribution: release_year_chart_data,
      highest_rated_decades: highest_rated_decades_data,
      genre_breakdown: genre_breakdown_data,
      country_breakdown: country_breakdown_data,
      language_breakdown: language_breakdown_data,
      top_actors: top_cast_data('Actor'),
      top_directors: top_cast_data('Director'),
      world_map_data: world_map_data,
      rewatches_count: calculate_rewatches,
      reviewed_films: @member.reviews.count
    }
  end

  def by_year_statistics
    {
      year: @year,
      total_films: @watched_entries.count,
      total_hours: calculate_total_hours,
      average_rating: calculate_average_rating_for_year,
      weekly_watches: weekly_watches_data,
      first_watch: @watched_entries.order(:watched_date).first,
      last_watch: @watched_entries.order(:watched_date).last,
      genre_breakdown: genre_breakdown_data,
      country_breakdown: country_breakdown_data,
      language_breakdown: language_breakdown_data,
      release_type_distribution: release_type_distribution_data,
      rating_spread: rating_spread_data,
      top_actors: top_cast_data('Actor'),
      top_directors: top_cast_data('Director'),
      most_liked_review: most_liked_review_of_year,
      world_map_data: world_map_data,
      highest_rated_unwatched: highest_rated_unwatched_films
    }
  end

  def calculate_total_hours
    @watched_entries.sum { |entry| entry.movie.runtime.to_i } / 60.0
  end

  def calculate_average_rating
    movie_ids = @watched_entries.pluck(:movie_id)
    ratings = @member.ratings.where(movie_id: movie_ids)
    return 0 if ratings.empty?

    (ratings.sum(:rating).to_f / ratings.count).round(2)
  end

  def calculate_average_rating_for_year
    movie_ids = @watched_entries.pluck(:movie_id)
    ratings = @member.ratings.where(movie_id: movie_ids)
    return 0 if ratings.empty?

    (ratings.sum(:rating).to_f / ratings.count).round(2)
  end

  def release_year_chart_data
    @watched_entries.group_by { |entry| entry.movie.release_date&.year }
                    .transform_values(&:count)
                    .reject { |k, _| k.nil? }
                    .sort
                    .to_h
  end

  def highest_rated_decades_data
    decades = {}
    movie_ids = @watched_entries.pluck(:movie_id)
    
    @member.ratings.where(movie_id: movie_ids)
            .includes(:movie)
            .each do |rating|
      decade_year = (rating.movie.release_date&.year.to_i / 10) * 10
      next if decade_year.nil? || decade_year == 0

      decade_label = "#{decade_year}s"
      decades[decade_label] ||= []
      decades[decade_label] << rating.rating
    end

    decades.transform_values { |ratings| (ratings.sum.to_f / ratings.count).round(2) }
           .sort_by { |_, v| -v }
           .to_h
  end

  def genre_breakdown_data
    movie_ids = @watched_entries.pluck(:movie_id)
    Genre.joins(:movies)
         .where(movies: { id: movie_ids })
         .group('genres.id', 'genres.name')
         .count
         .transform_keys { |keys| keys.last }
         .sort_by { |_, v| -v }
         .first(10)
         .to_h
  end

  def country_breakdown_data
    @watched_entries.map { |entry| entry.movie.origin_country }
                    .compact
                    .group_by { |c| c }
                    .transform_values(&:count)
                    .sort_by { |_, v| -v }
                    .first(10)
                    .to_h
  end

  def language_breakdown_data
    @watched_entries.map { |entry| entry.movie.language }
                    .compact
                    .group_by { |l| l }
                    .transform_values(&:count)
                    .sort_by { |_, v| -v }
                    .first(10)
                    .to_h
  end

  def top_cast_data(job)
    movie_ids = @watched_entries.pluck(:movie_id)
    
    result = Cast.joins(:credits)
                 .where(credits: { job: job, movie_id: movie_ids })
                 .group('casts.id', 'casts.name')
                 .count
                 .transform_keys { |keys| keys.last }
                 .sort_by { |_, v| -v }
                 .first(10)
                 .to_h
    
    result
  end

  def world_map_data
    @watched_entries.map { |entry| entry.movie.origin_country }
                    .compact
                    .group_by { |c| c }
                    .transform_values(&:count)
  end

  def weekly_watches_data
    @watched_entries.group_by { |entry| entry.watched_date.strftime('%Y-W%V') }
                    .transform_values(&:count)
                    .sort
                    .to_h
  end

  def release_type_distribution_data
    year_start = Date.new(@year, 1, 1)
    year_end = Date.new(@year, 12, 31)
    {
      releases: @watched_entries.joins(:movie).where(movies: { release_date: year_start..year_end }).count,
      rewatches: calculate_rewatches,
      reviewed: @member.reviews.where(created_at: year_start..year_end).count
    }
  end

  def rating_spread_data
    movie_ids = @watched_entries.pluck(:movie_id)
    @member.ratings.where(movie_id: movie_ids)
            .group(:rating)
            .count
            .sort
            .to_h
  end

  def most_liked_review_of_year
    year_start = Date.new(@year, 1, 1)
    year_end = Date.new(@year, 12, 31)
    @member.reviews.where(created_at: year_start..year_end)
            .left_joins(:likes)
            .group('reviews.id')
            .order('COUNT(likes.id) DESC')
            .first
  end

  def highest_rated_unwatched_films
    movie_ids = @watched_entries.pluck(:movie_id)
    year_start = Date.new(@year, 1, 1)
    year_end = Date.new(@year, 12, 31)
    Movie.where.not(id: movie_ids)
         .where(release_date: year_start..year_end)
         .limit(10)
  end

  def calculate_rewatches
    movie_ids = @watched_entries.pluck(:movie_id)
    @member.ratings.where(movie_id: movie_ids).count - @watched_entries.count
  end
end
