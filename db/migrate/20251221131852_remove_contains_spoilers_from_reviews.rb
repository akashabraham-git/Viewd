class RemoveContainsSpoilersFromReviews < ActiveRecord::Migration[7.2]
  def change
    remove_column :reviews, :contains_spoilers, :boolean if column_exists?(:reviews, :contains_spoilers)
  end
end
