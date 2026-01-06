ActiveAdmin.register Cast do
  permit_params :name, :bio, :tmdb_id, :pic

  scope :all, default: true
  scope :actors
  scope :crew

  filter :name
  filter :movies_title_cont, label: "Search by Filmography (Movie Title)"
  filter :tmdb_id
  filter :credits_job, as: :select, collection: -> { Credit.pluck(:job).uniq }, label: 'Job Title'

  index do
    selectable_column
    id_column
    column :pic do |c|
      image_tag c.pic, width: '40' if c.pic.present?
    end
    column :name
    column :job do |c| c.credits.pluck(:job).uniq.join(", ") end
    column :tmdb_id
    actions
  end

  show do
    attributes_table do
      row :name
      row :tmdb_id
      row :bio
      row :pic do |c|
        image_tag c.pic, width: '200' if c.pic.present?
      end
    end

    cast.credits.group_by(&:job).each do |job, credits|
      panel "As #{job}" do
        table_for credits do
          column "Movie" do |credit| 
            link_to credit.movie.title, admin_movie_path(credit.movie) 
          end
          
          if job == 'Actor'
            column :character 
          end
          
          column "Release Date" do |credit|
            credit.movie.release_date
          end
        end
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :tmdb_id
      f.input :pic
      f.input :bio, as: :text
    end
    f.actions
  end
end