class RemoveColumnTrailerFromMovies < ActiveRecord::Migration[7.2]
  def change
    remove_column :movies, :trailer, :string if column_exists?(:movies, :trailer)
  end
end
