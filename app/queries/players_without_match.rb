class PlayersWithoutMatch < Patterns::Query
  queries Player

  private

  def query
    relation.default.where.not(id: Player.joins(matches: :round).where('rounds.id = ?', round.id))
  end

  def round
    @round ||= options.fetch(:round)
  end
end
