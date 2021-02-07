class ResetSeasonRankings < Patterns::Service
  pattr_initialize :season

  def call
    return # no more used
    reset_season_rankings!
  end

  private

  def reset_season_rankings!
    rankings_hashes = RecalculatedRankings.result_for(season: season)

    puts "Importing into DB..."
    columns_to_update = [
      :points,
      :handicap,
      :sets_difference,
      :games_difference,
      :relevant
    ]

    Ranking.import rankings_hashes.map { |h| h.except(:player_name, :round_position) },
        on_duplicate_key_update: { conflict_target: [:id], columns: columns_to_update }

    puts "\nDone.\n"
  end
end
