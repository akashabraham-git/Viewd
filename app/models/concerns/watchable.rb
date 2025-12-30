module Watchable extend ActiveSupport::Concern
  included do
    after_save :mark_as_watched
  end

  private

  def mark_as_watched
    @current_user = User.second
    entry = LibraryEntry.find_or_initialize_by(member: @current_user.actable, movie: movie)
    if entry.watched_date.nil?
      entry.update(watched_date: Date.today, in_watchlist: false)
    end
  end
end