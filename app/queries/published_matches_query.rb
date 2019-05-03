class PublishedMatchesQuery < Patterns::Query
  queries Match

  private

  def query
    round.matches.published.includes(:player1, :player2)
  end

  def round
    options.fetch(:round)
  end
end
