ActiveAdmin.register LibraryEntry do
  permit_params :watched_date, :in_watchlist, :member_id, :movie_id

  scope :all, default: true
  scope :watchlist
  scope :watched

  batch_action :mark_as_watched do |ids|
    batch_action_collection.find(ids).each do |entry|
      entry.update(watched_date: Date.today, in_watchlist: false)
    end
    redirect_to collection_path, notice: "Selected movies marked as watched!"
  end

  filter :movie
  filter :watched_date
  filter :member_user_username_cont, label: "Member username"


  index do
    selectable_column
    column :movie
    column "Member" do |c| link_to c.member.user.username, admin_member_path(c.member) end
    column :watched_date
    column :in_watchlist
    actions
  end


  form do |f|
    f.inputs do
      f.input :movie
      f.input :member, collection: Member.all.map { |m| [m.user.username, m.id] }
      f.input :in_watchlist, as: :boolean
      f.input :watched_date
    end
    f.actions
  end

end

