class PublishedMatchesQuery < Patterns::Query
  queries Match

  private

  def query
    round.matches.published
        .includes(:player1, :player2)
        .order(finished_at: :desc, play_date: :desc, created_at: :desc)
  end

  def round
    options.fetch(:round)
  end
end
