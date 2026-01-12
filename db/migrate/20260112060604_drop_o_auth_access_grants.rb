class DropOAuthAccessGrants < ActiveRecord::Migration[7.2]
  def change
    drop_table :oauth_access_grants if table_exists?(:oauth_access_grants)
    change_column_null :oauth_applications, :redirect_uri, true
  end
end
