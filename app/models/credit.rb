class Credit < ApplicationRecord
  belongs_to :cast
  belongs_to :movie

  before_save :normalize_character

  def normalize_character
    self.character = character.squish.titleize if character.present?
  end

  def self.ransackable_attributes(auth_object = nil)
    ["cast_id", "movie_id", "character", "job"]
  end

    def self.ransackable_associations(auth_object = nil)
    ["cast", "movie"]
  end

end
