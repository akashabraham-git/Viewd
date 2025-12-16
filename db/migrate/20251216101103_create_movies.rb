class CreateMovies < ActiveRecord::Migration[7.2]
  def change
    create_table :movies do |t|
      t.string :title
      t.integer :tmdb_id
      t.date :release_date
      t.string :poster_url
      t.integer :language
      t.integer :runtime
      t.string :trailer
      t.text :synopsis
      t.integer :origin_country
      t.integer :status

      t.timestamps
    end
  end
end
