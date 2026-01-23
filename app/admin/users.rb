ActiveAdmin.register User do

  permit_params :email, :username, :name, :password, :password_confirmation

  filter :email
  filter :username
  filter :name
  filter :created_at


  scope :all, default: true
  scope :member
  scope :moderator
  scope "Deleted", :only_deleted

  config.remove_action_item(:new) 
  actions :all, except: [:new, :create]

  action_item :restore, only: :show, if: proc { resource.deleted? } do
    link_to "Restore User", restore_admin_user_path(resource), method: :put
  end

  batch_action :delete_permanently, confirm: "This is irreversible. Purge these users?" do |ids|
    User.with_deleted.where(id: ids).find_each(&:purge_entirely!)
    redirect_to collection_path, notice: "Selected users have been wiped from the database."
  end

  member_action :restore, method: :put do
    resource = User.with_deleted.find(params[:id])
    if resource.recover
      redirect_to admin_user_path(resource), notice: "User has been successfully restored!"
    else
      redirect_to admin_user_path(resource), alert: "Failed to restore user."
    end
  end

  index do
    selectable_column
    id_column
    column :username
    column :email
    column :name
    column :actable_type if params[:scope] == 'all'
    column :created_at
    actions do |user|
      if user.deleted?
        item "Restore", restore_admin_user_path(user), method: :put, class: "member_link"
      end
    end
  end

  show do
    attributes_table do
      row :username
      row :email
      row :name
      row :actable_type
      
      if user.actable_type == 'Member'
        row :bio do
          user.actable.bio
        end
        row :country do
          user.actable.country
        end
        row "Member" do |m| 
          link_to m.actable.id, admin_member_path(m.actable) 
        end 
      else
        row "Moderator" do |m| 
          link_to m.actable.id, admin_moderator_path(m.actable) 
        end 
      end
    end
  end

  form do |f|
    f.inputs "Account Details" do
      f.input :username
      f.input :email
      f.input :name
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

  controller do
    def scoped_collection
      super.with_deleted
    end

    def update
      if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
      end
      super
    end
  end

end
