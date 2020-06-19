class Ranking < ApplicationRecord
  belongs_to :player
  belongs_to :round

  validates :player, uniqueness: { scope: :round }
  validates :points,
            :handicap,
            :sets_difference,
            :games_difference,
            presence: true

  def handicap2
    opponents = Player.joins(matches: :round).merge(Match.finished)
                    .where("rounds.position <= ?", self.round.position)
                    .where("rounds.season_id = ?", self.round.season_id)
                    .where("matches.player1_id = ? OR matches.player2_id = ?", self.player_id, self.player_id)
                    .where.not(id: self.player_id)
                    .where("matches.winner_id = ? or (matches.set1_player1_score is not null or matches.set1_player2_score is not null)", self.player_id)

    Ranking.joins(:round)
        .where(player_id: opponents.ids)
        .where(rounds: { season_id: self.round.season_id })
        .where("rounds.position = ?", self.round.position).inject(0) { |sum, ranking| sum += ranking.points }
  end
end
