class AddMemberIdToRatings < ActiveRecord::Migration[7.2]
  def change
    remove_reference :ratings, :user, foreign_key: true
    add_reference :ratings, :member, foreign_key: true
    drop_table :list_items if table_exists?(:list_items)
    drop_table :lists if table_exists?(:lists)
  end
end
