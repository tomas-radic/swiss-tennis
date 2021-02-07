class Ranking < ApplicationRecord
  before_validation :set_defaults

  belongs_to :player
  belongs_to :round

  validates :player, uniqueness: { scope: :round }
  validates :points,
            :sets_difference,
            :games_difference,
            presence: true

  private

  def set_defaults
    self.points ||= 0
    self.sets_difference ||= 0
    self.games_difference ||= 0
  end
end
