class RankingQuery < Patterns::Query
  queries Ranking

  private

  def query
    relation.joins(:player).where(round: round)
        .order(points: :desc, handicap: :desc, games_difference: :desc)
        .order('players.created_at asc')
  end

  def round
    @round ||= options.fetch(:round)
  end
end
