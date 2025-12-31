class RemoveModeratoridFromMovie < ActiveRecord::Migration[7.2]
  def change
    remove_column :movies, :moderator_id, :integer if column_exists?(:movies, :moderator_id)
  end
end
