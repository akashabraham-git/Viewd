class CreateCasts < ActiveRecord::Migration[7.2]
  def change
    create_table :casts do |t|
      t.string :name
      t.text :bio
      t.integer :tmdb_id
      t.string :pic

      t.timestamps
    end
  end
end
