object @membership => :membership

attributes :id, :status, :started_at, :expires_at, :transaction_id

child :membership_tier do
  attributes :name, :badge, :price
end