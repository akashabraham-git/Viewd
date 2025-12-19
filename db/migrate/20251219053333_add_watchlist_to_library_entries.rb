class AddWatchlistToLibraryEntries < ActiveRecord::Migration[7.2]
  def change
    add_column :library_entries, :watchlist, :boolean, default: false
  end
end
