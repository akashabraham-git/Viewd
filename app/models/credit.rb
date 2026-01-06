class Credit < ApplicationRecord
  belongs_to :cast
  belongs_to :movie

  before_save :normalize_character

  scope :actors, -> { where(job: 'Actor') }
  scope :crew, -> { where.not(job: 'Actor') }

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
