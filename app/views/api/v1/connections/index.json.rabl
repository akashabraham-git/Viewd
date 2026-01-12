collection @users, root: "users", object_root: false

node(:id) { |actable| actable.user&.id }
node(:username) { |actable| actable.user&.username }
node(:name) { |actable| actable.user&.name }
node(:profile_picture_url) do |actable|
  if actable.profile_picture.attached?
    Rails.application.routes.url_helpers.rails_blob_url(actable.profile_picture, only_path: true)
  else
    nil
  end
end