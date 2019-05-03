class MatchAssignment < ApplicationRecord
  belongs_to :player
  belongs_to :match

  validates :match, uniqueness: { scope: :player }
end
