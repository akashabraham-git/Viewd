class CreateListItems < ActiveRecord::Migration[7.2]
  def change
    create_table :list_items do |t|
      t.references :list, null: false, foreign_key: true
      t.references :movie, null: false, foreign_key: true
      t.integer :rank

      t.timestamps
    end
  end
end
