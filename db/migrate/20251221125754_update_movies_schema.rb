class UpdateMoviesSchema < ActiveRecord::Migration[7.2]
  def change
    change_column :movies, :language, :string
  end
end
