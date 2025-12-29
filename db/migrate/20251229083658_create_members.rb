class CreateMembers < ActiveRecord::Migration[7.2]
  def change
    create_table :members do |t|
      t.text :bio
      t.integer :country

      t.timestamps
    end
  end
end
