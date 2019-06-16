class DraftMatchesQuery < Patterns::Query
  queries Match

  private

  def query
    round.matches.draft.includes(player1: :rankings, player2: :rankings)
  end

  def round
    options.fetch(:round)
  end
end
