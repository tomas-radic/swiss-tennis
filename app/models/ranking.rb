class Ranking < ApplicationRecord
  belongs_to :player
  belongs_to :round

  validates :player, uniqueness: { scope: :round }
  validates :points,
            :toss_points,
            :handicap,
            :sets_difference,
            :games_difference,
            presence: true

end
