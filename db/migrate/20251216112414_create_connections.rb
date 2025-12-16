class CreateConnections < ActiveRecord::Migration[7.2]
  def change
    create_table :connections do |t|
      t.integer :follower_id
      t.integer :following_id

      t.timestamps
    end

    add_foreign_key :connections, :users, column: :follower_id
    add_foreign_key :connections, :users, column: :following_id
  end
end
