class CreateMembershipTiers < ActiveRecord::Migration[7.2]
  def change
    create_table :membership_tiers do |t|
      t.string :name
      t.integer :price
      t.boolean :has_ads
      t.integer :badge
      t.boolean :can_view_stats
      t.integer :country

      t.timestamps
    end
  end
end
