collection @tiers, root: "membership_tiers", object_root: false

attributes :id, :name, :price, :badge, :has_ads, :can_view_stats

node(:country) { |tier| tier.country.upcase }