class PlayerRankingsSinceRoundQuery < Patterns::Query
  queries Ranking

  private

  def query
    relation.joins(:round)
        .where('rounds.season_id = ? and rounds.position >= ?', round.season_id, round.position)
        .where('rankings.player_id = ?', player.id)
  end

  def player
    @player ||= options.fetch(:player)
  end

  def round
    @round ||= options.fetch(:round)
  end
end
