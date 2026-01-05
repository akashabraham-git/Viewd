ActiveAdmin.register Member do
  permit_params :bio, :country, 
                user_attributes: [:id, :username, :email, :password, :password_confirmation]

  scope :all, default: true
  
  filter :user_username, label: "Username"
  filter :user_email, label: "Email"
  filter :country, as: :select, collection: -> { Member.pluck(:country).uniq }
  filter :membership_status, as: :select, collection: -> { Membership.statuses }

  index do
    selectable_column
    id_column
    column :username do |m| m.user&.username end
    column :email do |m| m.user&.email end
    column :country
    column "Status" do |m|
      status_tag m.membership&.status || "No Membership"
    end
    actions
  end

  show title: ->(m) { m.user&.username } do
    attributes_table do
      row :username do |m| m.user&.username end
      row :email do |m| m.user&.email end
      row :bio
      row :country
      row :created_at
    end
    
    panel "Membership History" do
      table_for member.membership do
        column :membership_tier
        column :status
        column :expires_at
      end
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs "User Account", for: [:user, f.object.user || f.object.build_user] do |u|
      u.input :username
      u.input :name
      u.input :email
      u.input :password
      u.input :password_confirmation
    end
    f.inputs "Member Profile" do
      f.input :bio
      f.input :country, as: :string
    end
    f.actions
  end

  action_item :view_following, only: :show do
    link_to "View Following List", admin_connections_path("q[follower_id_eq]" => member.id)
  end

  action_item :view_followers, only: :show do
    link_to "View Followers List", admin_connections_path("q[following_id_eq]" => member.id)
  end

  sidebar "Connection Stats", only: :show do
    attributes_table_for member do
      row("Following Count") { member.following.count }
      row("Followers Count") { member.followers.count }
    end
  end

end
