class RankingsQuery < Patterns::Query
  queries Ranking

  private

  def query
    relation.joins(:player)
        .where('players.dummy is false')
        .where(round: round)
        .order(relevant: :desc, points: :desc, handicap: :desc, sets_difference: :desc, games_difference: :desc)
        .order('players.created_at asc')
        .includes(:round, player: :matches)
  end

  def round
    @round ||= options.fetch(:round)
  end
end
