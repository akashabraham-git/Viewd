ActiveAdmin.register MembershipTier do
  permit_params :name, :price, :has_ads, :badge, :can_view_stats, :country

  filter :name
  filter :price
  filter :country
  filter :badge, as: :select, collection:  MembershipTier.badges

  scope :all, default: true
  scope :free
  scope :pro
  scope :patron

  index do
    selectable_column
    id_column
    column :name
    column :price
    column :badge
    column :country
    column :has_ads
    column :can_view_stats
    actions
  end

  show do
    attributes_table do
      row :name
      row :price
      row :country
      row :badge
      row :has_ads
      row :can_view_stats
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs "Tier Details" do
      f.input :name
      f.input :price
      f.input :badge, as: :select, collection:  MembershipTier.badges
    end
    f.inputs "Permissions" do
      f.input :has_ads
      f.input :can_view_stats
    end
    f.actions
  end

end