class Cast < ApplicationRecord
  has_many :credits, dependent: :destroy
  has_many :movies, through: :credits

  validates :name, presence: true

  scope :actors, -> { joins(:credits).where(credits: { job: 'Actor'}).distinct }
  scope :crew, -> { joins(:credits).where.not(credits: { job: 'Actor'}).distinct }

  def self.ransackable_attributes(auth_object = nil)
    ["id", "name", "tmdb_id"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["movies", "credits"]
  end
end
