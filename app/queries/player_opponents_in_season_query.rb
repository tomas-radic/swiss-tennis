class PlayerOpponentsInSeasonQuery < Patterns::Query
  queries Player

  private

  def query
    relation.joins(matches: [round: :season])
        .where(rounds: { season_id: season.id })
        .where.not(matches: { finished_at: nil })
        .where('matches.player1_id = ? or matches.player2_id = ?', player.id, player.id)
        .where.not(players: { id: player.id })
  end

  def player
    options.fetch(:player)
  end

  def season
    options.fetch(:season)
  end
end
