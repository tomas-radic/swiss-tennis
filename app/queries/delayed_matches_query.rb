class DelayedMatchesQuery < Patterns::Query
  queries Match

  private

  def query
    relation.published.joins(round: :season)
        .where(seasons: { id: round.season_id })
        .where(matches: { finished_at: nil })
        .where('rounds.position < ?', round.position)
        .joins('join players as p1 on p1.id = matches.player1_id')
        .joins('join enrollments as e1 on e1.player_id = p1.id')
        .joins('join players as p2 on p2.id = matches.player2_id')
        .joins('join enrollments as e2 on e2.player_id = p2.id')
        .where('p1.dummy is false and p2.dummy is false')
        .where('e1.canceled_at is null and e2.canceled_at is null')
        .distinct
        .includes(:round, :place, :player1, :player2)
  end

  def round
    @round ||= options.fetch(:round)
  end
end
