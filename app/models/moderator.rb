class Moderator < ApplicationRecord
  has_one :user, as: :actable, dependent: :destroy
end