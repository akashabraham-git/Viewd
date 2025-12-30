class Credit < ApplicationRecord
  belongs_to :cast
  belongs_to :movie

  before_save :normalize_character

  def normalize_character
    self.character = character.squish.titleize if character.present?
  end
end
