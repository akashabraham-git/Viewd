class DropFavoritesAndUpdateLibraryEntries < ActiveRecord::Migration[7.2]
  def change
    rename_column :library_entries, :watchlist, :in_watchlist
    rename_column :library_entries, :date, :watched_date
    drop_table :favorites if table_exists?(:favorites)
  end
end
