class UnplannedMatchesCount < Patterns::Calculation

  private

  def result
    subject.published.pending
        .joins('join players as p1 on p1.id = matches.player1_id')
        .joins('join players as p2 on p2.id = matches.player2_id')
        .where('p1.dummy is false and p2.dummy is false')
        .where(play_date: nil).distinct.count
  end
end
