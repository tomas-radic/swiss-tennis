class Score < ApplicationRecord
  belongs_to :player
  belongs_to :round

  validates :points,
            :handicap,
            :games_difference,
            presence: true
end
