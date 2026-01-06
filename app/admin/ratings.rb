ActiveAdmin.register Rating do
  permit_params :rating, :member_id, :movie_id

  filter :movie
  filter :rating

  index do
    selectable_column
    column :movie
    column "Member" do |c| 
      link_to c.member.user.username, admin_member_path(c.member)
    end
    column "Stars" do |r|
      "★" * r.rating
    end
    actions
  end

  form do |f|
    f.inputs do
      f.input :movie
      f.input :member, collection: Member.all.map { |m| [m.user.username, m.id] }
      f.input :rating, as: :select, collection: (1..5)
    end
    f.actions
  end

end