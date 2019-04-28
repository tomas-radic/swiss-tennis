class PlayersWithoutMatch < Patterns::Query
  queries Player

  private

  def query
    players = relation.where.not(id: Player.joins(matches: :round).where('rounds.id = ?', round.id))
    players = players.where.not(dummy: true) unless include_dummy?
    players
  end

  def round
    @round ||= options.fetch(:round)
  end

  def include_dummy?
    options.fetch(:include_dummy, false)
  end
end
