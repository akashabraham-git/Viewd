ActiveAdmin.register Review do
  permit_params :content, :member_id, :movie_id

  filter :movie
  filter :member
  filter :content_cont, label: "Search Content"

  member_action :mark_violation, method: :put do
    resource.update(content: "[This review has been removed due to a violation of our terms of service]")
    redirect_to admin_review_path(resource), notice: "Review marked as violation and content removed."
  end

  action_item :violation_button, only: :show do
    link_to "Remove for Violation", mark_violation_admin_review_path(review), 
            method: :put, 
            data: { confirm: "Are you sure you want to remove this content for a violation?" }
  end

  batch_action :mark_violation, confirm: "Remove content from all selected reviews for violations?" do |ids|
    batch_action_collection.find(ids).each do |review|
      review.update(content: "[This review has been removed due to a violation of our terms of service]")
    end
    redirect_to collection_path, notice: "Selected reviews have been cleared for violations."
  end

  index do
    selectable_column
    id_column
    column :movie
    column :username do |r| link_to r.member.user.username, admin_member_path(r.member) end
    column :content do |r| truncate(r.content, length: 50) end
    column :created_at
    actions
  end

  show do 
    attributes_table do
      row :movie
      row :member
      row :username do |r| r.member.user.username end
      row :content
      row :created_at
    end
  end

  form do |f|
    f.inputs "Review Details" do
      f.input :movie
      f.input :member, collection: Member.all.map { |m| [m.user.username, m.id] }
      f.input :content, as: :text
    end
    f.actions
  end
end