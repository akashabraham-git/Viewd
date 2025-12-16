json.extract! user, :id, :username, :name, :email, :password, :bio, :profile_picture, :country, :created_at, :updated_at
json.url user_url(user, format: :json)
