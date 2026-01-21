class AddDeletedAtToMembers < ActiveRecord::Migration[7.2]
  def change
    add_column :members, :deleted_at, :datetime
    add_index :members, :deleted_at

    add_column :reviews, :deleted_at, :datetime
    add_index :reviews, :deleted_at

    add_column :likes, :deleted_at, :datetime
    add_index :likes, :deleted_at

    add_column :library_entries, :deleted_at, :datetime
    add_index :library_entries, :deleted_at

    add_column :connections, :deleted_at, :datetime
    add_index :connections, :deleted_at

    add_column :memberships, :deleted_at, :datetime
    add_index :memberships, :deleted_at

    add_column :ratings, :deleted_at, :datetime
    add_index :ratings, :deleted_at

  end
end
