class DraftMatchesQuery < Patterns::Query
  queries Match

  private

  def query
    round.matches.draft
        .order(created_at: :desc)
  end

  def round
    options.fetch(:round)
  end
end
