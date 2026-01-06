ActiveAdmin.register Like do
  permit_params :member_id, :likeable_id, :likeable_type

  scope :all, default: true
  scope :movie_likes
  scope :review_likes

  filter :member_user_username_cont, label: "Liker Username"
  filter :likeable_id, label: "Review/ Movie ID"

  index do
    selectable_column
    column "Liker" do |like|
      link_to like.member.user.username, admin_member_path(like.member)
    end

    column "Movie" do |like|
      movie = like.associated_movie
      link_to movie.title, admin_movie_path(movie) if movie
    end
    if params[:scope] == 'review_likes'
      column "Review Written By" do |like|
        like.likeable.member.user.username
      end
    end

    column "Item Type", :likeable_type if params[:scope] == 'all'
    actions
  end


  form do |f|
    f.semantic_errors 

    f.inputs "Liker Details" do
      f.input :member, collection: Member.joins(:user).map { |m| [m.user.username, m.id] }
    end

    f.inputs "Liked Item" do
      f.input :likeable_type, as: :select, collection: ["Movie", "Review"], include_blank: false
      f.input :likeable_id, as: :select, collection: grouped_options_for_select(
        "Movies" => Movie.pluck(:title, :id),
        "Reviews" => Review.joins(:movie).map { |r| ["##{r.id} #{r.movie.title} by #{r.member.user.username}", r.id] }
      )
    end

    f.actions
  end
  
end

