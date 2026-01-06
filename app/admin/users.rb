ActiveAdmin.register User do

  permit_params :email, :username, :name, :password, :password_confirmation

  filter :email
  filter :username
  filter :name
  filter :created_at


  scope :all, default: true
  scope :member
  scope :moderator

  config.remove_action_item(:new) 
  actions :all, except: [:new, :create]

  index do
    selectable_column
    id_column
    column :username
    column :email
    column :name
    column :actable_type if params[:scope] == 'all'
    column :created_at
    actions
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
    def update
      if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
      end
      super
    end
  end

end
