ActiveAdmin.register Connection do
  permit_params :follower_id, :following_id

  filter :follower_user_username_cont, label: "Follower Username"
  filter :following_user_username_cont, label: "Following Username"
  filter :created_at

  index do
    selectable_column
    id_column
    column "Follower" do |conn|
      link_to conn.follower.user.username, admin_member_path(conn.follower)
    end
    column "Following" do |conn|
      link_to conn.following.user.username, admin_member_path(conn.following)
    end
    column :created_at
    actions
  end

  form do |f|
    f.semantic_errors
    f.inputs "Connection Details" do
      f.input :follower, collection: Member.all.map { |m| [m.user&.username, m.id] }
      f.input :following, collection: Member.all.map { |m| [m.user&.username, m.id] }
    end
    f.actions
  end
end