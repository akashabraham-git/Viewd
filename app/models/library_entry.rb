class LibraryEntry < ApplicationRecord
  belongs_to :movie
  belongs_to :member
end
