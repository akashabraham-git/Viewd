class CreateLibraryEntries < ActiveRecord::Migration[7.2]
  def change
    create_table :library_entries do |t|
      t.references :movie, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.boolean :watched
      t.date :date

      t.timestamps
    end
  end
end
