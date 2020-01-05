class PlayersWithoutMatchQuery < Patterns::Query
  queries Player

  private

  def query
    players_with_match = relation.joins(matches: :round).where(rounds: { id: round.id })
    players = relation.active
                  .left_joins(enrollments: :season)
                  .where('(seasons.id = ?) or (players.dummy is true)', round.season_id)
                  .where.not(players: { id: players_with_match.ids })
                  .order(:last_name)

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
