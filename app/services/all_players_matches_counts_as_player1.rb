class AllPlayersMatchesCountsAsPlayer1 < Patterns::Service
  pattr_initialize :season

  def call
    season.players.joins(player1_matches: [round: :season])
        .where(rounds: { season_id: season.id })
        .group('matches.player1_id').count
  end
end
