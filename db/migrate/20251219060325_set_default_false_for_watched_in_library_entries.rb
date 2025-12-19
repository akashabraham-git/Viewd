class SetDefaultFalseForWatchedInLibraryEntries < ActiveRecord::Migration[7.2]
  def change
    change_column_default :library_entries, :watched, from: nil, to: false
  end
end
