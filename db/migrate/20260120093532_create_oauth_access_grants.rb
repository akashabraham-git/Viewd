class CreateOauthAccessGrants < ActiveRecord::Migration[7.2]
  def change
    create_table :oauth_access_grants do |t|
      t.references :resource_owner,  null: false
      t.references :application,     null: false
      t.string   :token,             null: false
      t.integer  :expires_in,        null: false
      t.text     :redirect_uri,      null: false
      t.datetime :created_at,        null: false
      t.datetime :revoked_at
      t.string   :scopes,            null: false, default: ''
    end

    add_index :oauth_access_grants, :token, unique: true
  end
end