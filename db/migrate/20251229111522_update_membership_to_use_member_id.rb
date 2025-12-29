class UpdateMembershipToUseMemberId < ActiveRecord::Migration[7.2]
  def change
    remove_reference :memberships, :user, foreign_key: true
    add_reference :memberships, :member, foreign_key: true

    remove_reference :reviews, :user, foreign_key: true
    add_reference :reviews, :member, foreign_key: true

    remove_reference :likes, :user, foreign_key: true
    add_reference :likes, :member, foreign_key: true

    remove_reference :library_entries, :user, foreign_key: true
    add_reference :library_entries, :member, foreign_key: true

    remove_column :connections, :follower_id, :bigint
    remove_column :connections, :following_id, :bigint

    add_reference :connections, :follower, foreign_key: { to_table: :members }
    add_reference :connections, :following, foreign_key: { to_table: :members }
  end
end
