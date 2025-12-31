class RemoveColumnPasswordFromUser < ActiveRecord::Migration[7.2]
  def change
    remove_column :users, :password, :string if column_exists?(:users, :password)
  end
end
