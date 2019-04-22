class Ranking < ApplicationRecord
  belongs_to :player
  belongs_to :round

  validates :player, uniqueness: { scope: :round }
  validates :points,
            :handicap,
            :games_difference,
            presence: true

end
