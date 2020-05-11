class RankingsQuery < Patterns::Query
  queries Ranking

  private

  def query
    relation.joins(player: :enrollments)
        .where('players.dummy is false')
        .where(round: round)
        .where(enrollments: { season_id: round&.season_id })
        .order(
            relevant: :desc,
            points: :desc,
            handicap: :desc,
            sets_difference: :desc,
            games_difference: :desc
        )
        .order('enrollments.created_at asc')
        .includes(:round, player: [:matches, :category])
  end

  def round
    @round ||= options.fetch(:round)
  end
end
