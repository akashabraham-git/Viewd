class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :username
      t.string :name
      t.string :email
      t.string :password
      t.string :bio
      t.string :profile_picture
      t.integer :country

      t.timestamps
    end
  end
end
