class CreateLists < ActiveRecord::Migration[7.2]
  def change
    create_table :lists do |t|
      t.string :title
      t.text :description
      t.boolean :is_ranked
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
