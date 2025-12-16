class CreateMemberships < ActiveRecord::Migration[7.2]
  def change
    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :membership_tier, null: false, foreign_key: true
      t.integer :status
      t.datetime :started_at
      t.datetime :expires_at
      t.string :transaction_id

      t.timestamps
    end
  end
end
