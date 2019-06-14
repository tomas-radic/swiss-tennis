class AllPlayersMatchesCountsAsPlayer1 < Patterns::Service
  pattr_initialize :season

  def call
    Player.joins(player1_matches: [round: :season])
        .where(seasons: { id: season.id })
        .group('matches.player1_id').count
  end
end
