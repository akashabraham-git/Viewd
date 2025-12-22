class UpdateMoviesAndCreditsSchema < ActiveRecord::Migration[7.2]
  def change
      change_column :movies, :origin_country, :string

      remove_column :credits, :role, :string if column_exists?(:credits, :role)
      add_column :credits, :character, :string
      add_column :credits, :job, :string
    end
end
