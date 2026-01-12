attributes :id, :content, :created_at, :updated_at

node(:likes_count) { |review| review.likes.size }

child :member do
  attributes :id
  node(:name) { |member| member.user&.name }
  node(:username) { |member| member.user&.username }
  node(:bio) { |member| member.bio }
  node(:profile_picture_url) do |member|
    if member.profile_picture.attached?
      Rails.application.routes.url_helpers.rails_blob_url(member.profile_picture, only_path: true)
    else
      nil
    end
  end
end

child :movie do
  attributes :id, :title, :poster_url, :release_date
end
