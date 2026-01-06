ActiveAdmin.register Genre do
  permit_params :name

  filter :name

  index do
    selectable_column
    id_column
    column :name
    column "Movies Count" do |genre|
      genre.movies.count
    end
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
    end
    panel "Movies in this Genre" do
      table_for genre.movies do
        column :title do |m| link_to m.title, admin_movie_path(m) end
        column :release_date
        column :status
      end
    end
  end
end