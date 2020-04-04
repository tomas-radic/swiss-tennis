class PlayersWithoutMatchQuery < Patterns::Query
  queries Player

  private

  def query
    players_with_match = relation.joins(matches: :round).where(rounds: { id: round.id })
    players = relation.active
                  .left_joins(:rounds, enrollments: :season).where(
                    'players.dummy is true or (enrollments.season_id = ? and rankings.round_id = ?)',
                    round.season_id,
                    round.id)
                  .where(enrollments: { canceled_at: nil })
                  .where.not(players: { id: players_with_match.ids })
                  .order(:last_name).distinct

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
