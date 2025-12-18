class RemoveColumnsFromReviews < ActiveRecord::Migration[7.2]
  def change
    remove_column :reviews, :watched_on, :date
    remove_column :reviews, :is_rewatch, :boolean
  end
end
