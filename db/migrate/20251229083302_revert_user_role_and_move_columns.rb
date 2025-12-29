class RevertUserRoleAndMoveColumns < ActiveRecord::Migration[7.2]
  def change
    
    remove_column :users, :bio, :string
    remove_column :users, :country, :integer
    
    add_column :users, :actable_id, :integer
    add_column :users, :actable_type, :string
  end
end
