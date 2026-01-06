ActiveAdmin.register Credit do
  permit_params :cast_id, :movie_id, :character, :job

  scope :all, default: true
  scope :actors
  scope :crew

  filter :movie
  filter :cast_name_cont, label: "Member Name"
  filter :character
  filter :job, as: :select, collection: -> { Credit.pluck(:job).uniq }

  index do
    selectable_column
    id_column
    column :movie
    column "Member" do |c| link_to c.cast.name, admin_cast_path(c.cast) end
    column :character
    column :job
    column :created_at
    actions
  end
end
