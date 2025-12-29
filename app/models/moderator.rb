class Moderator < ApplicationRecord
  has_one :user, as: :actable, dependent: :destroy
  has_many :managed_movies, class_name: "Movie", foreign_key: "moderator_id"
end