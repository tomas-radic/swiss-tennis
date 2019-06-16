class PublishedMatchesQuery < Patterns::Query
  queries Match

  private

  def query
    round.matches.published.includes(player1: :rankings, player2: :rankings)
  end

  def round
    options.fetch(:round)
  end
end
