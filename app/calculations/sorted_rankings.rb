class SortedRankings < Patterns::Calculation

  private

  def result
    matches_hashes = round.season.matches.finished.joins(:round)
                         .where("rounds.position <= ?", round.position)
                         .includes(:round).map do |match|
      {
          id: match.id,
          round: match.round.position,
          player1_id: match.player1_id,
          player2_id: match.player2_id,
          winner_id: match.winner_id,
          set1_player1_score: match.set1_player1_score,
          set1_player2_score: match.set1_player2_score
      }
    end

    round_rankings = round.rankings

    rankings_hashes = round_rankings.includes(:round).map do |ranking|
      {
          player_id: ranking.player_id,
          round: ranking.round.position,
          points: ranking.points
      }
    end

    @rankings = round_rankings.joins(:player)
                    .where(players: { dummy: false })
                    .where(rankings: { round_id: round.id })
                    .includes(player: [:matches, :category, { enrollments: :season }]).map do |ranking|
      {
          relevant: ranking.relevant? ? 1 : 0,
          points: ranking.points,
          handicap: Handicap.result_for(ranking: ranking,
                                        finished_season_matches: matches_hashes,
                                        round_rankings: rankings_hashes),
          sets_difference: ranking.sets_difference,
          games_difference: ranking.games_difference,
          enrollment_time: ranking.player.enrollments.find { |e| e.season_id == round.season_id }.created_at,
          round_match_finished: ranking.player.matches.any? { |m| m.round_id == round.id && m.finished? },
          player: ranking.player
      }
    end

    @rankings = @rankings.sort_by do |ranking|
      [
          -ranking[:relevant],
          -ranking[:points],
          -ranking[:handicap],
          -ranking[:sets_difference],
          -ranking[:games_difference],
          ranking[:enrollment_time]
      ]
    end
  end

  def round
    @round ||= options.fetch(:round)
  end
end
