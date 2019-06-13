class PlayerOpponentsUpToRoundQuery < Patterns::Query
  queries Player

  private

  def query
    relation.joins(matches: { round: :season })
        .where('seasons.id = ?', round.season_id)
        .where('rounds.position < ?', round.position)
        .where('matches.player1_id = ? or matches.player2_id = ?', player.id, player.id)
        .where('matches.finished_at is not null')
        .where.not(id: player.id)
  end

  def player
    options.fetch(:player)
  end

  def round
    options.fetch(:round)
  end
end
