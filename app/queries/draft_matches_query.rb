class DraftMatchesQuery < Patterns::Query
  queries Match

  private

  def query
    round.matches.draft.includes(:player1, :player2)
  end

  def round
    options.fetch(:round)
  end
end
