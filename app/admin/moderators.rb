ActiveAdmin.register Moderator do
  permit_params :employee_number, :department, 
                user_attributes: [:id, :username, :email, :password, :password_confirmation]

  filter :user_username, label: "Username"
  filter :department, as: :select, collection: -> { Moderator.pluck(:department).uniq }
  filter :employee_number

  index do
    selectable_column
    column :employee_number
    column :department
    column :username do |mod| mod.user&.username end
    column :email do |mod| mod.user&.email end
    actions
  end

  show do
    attributes_table do
      row :username do |mod| mod.user&.username end
      row :email do |mod| mod.user&.email end
      row :created_at
      row :employee_number
      row :department
    end
  end

  form do |f|
    f.semantic_errors

    f.inputs "Account Access", for: [:user, f.object.user || f.object.build_user] do |u|
      u.input :username
      u.input :email
      u.input :password
      u.input :password_confirmation
    end
    f.inputs "Staff Information" do
      f.input :employee_number
      f.input :department, as: :select, collection: ["Support", "Content", "Admin"]
    end
    f.actions
  end
end