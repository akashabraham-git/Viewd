class CreateCredits < ActiveRecord::Migration[7.2]
  def change
    create_table :credits do |t|
      t.references :cast, null: false, foreign_key: true
      t.references :movie, null: false, foreign_key: true
      t.string :role

      t.timestamps
    end
  end
end
