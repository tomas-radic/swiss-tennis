class PlayerSeasonMatchesQuery < Patterns::Query
  queries Match

  private

  def query
    relation.published.joins(round: :season)
        .where(seasons: { id: season.id })
        .where('matches.player1_id = ? or matches.player2_id = ?', player.id, player.id)
        .reorder('rounds.position desc, matches.finished_at desc nulls first')
  end

  def player
    options.fetch(:player)
  end

  def season
    options.fetch(:season)
  end
end
