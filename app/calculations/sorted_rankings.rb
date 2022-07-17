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
          retired_player_id: match.retired_player_id,
          set1_player1_score: match.set1_player1_score,
          set1_player2_score: match.set1_player2_score
      }
    end

    round_rankings = round.rankings

    rankings_hashes = round_rankings.includes(:round).map do |ranking|
      {
          player_id: ranking.player_id,
          round: ranking.round,
          points: ranking.points
      }
    end

    enrollments = round.season.enrollments.to_a

    @rankings = round_rankings.joins(:player)
                    .where(players: { dummy: false })
                    .where(rankings: { round_id: round.id })
                    .includes(player: [:matches, :category, { enrollments: :season }]).map do |ranking|
      {
          relevant: ranking.relevant? ? 1 : 0,
          points: ranking.points,
          handicap: Handicap.result_for(ranking: ranking,
                                        finished_season_matches: matches_hashes,
                                        round_rankings: rankings_hashes,
                                        enrollments: enrollments,
                                        substitute_points: substitute_points_from(
                                           rankings_hashes, enrollments
                                         )),
          sets_difference: ranking.sets_difference,
          games_difference: ranking.games_difference,
          enrollment_time: enrollments.find { |e| e.player_id == ranking.player_id }.created_at,
          all_matches_finished: ranking.player.matches.published.all? { |m| m.finished? },
          player: ranking.player,
          player_enrollment_active: ranking.player.enrollments.find { |e| e.season_id == round.season_id && e.canceled_at.nil? }.present?,
          updated_at: ranking.updated_at
      }
    end

    sort_rankings!
    set_positions!

    @rankings
  end


  def sort_rankings!
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


  def set_positions!
    last_point_level_ranking = nil

    @rankings.map.with_index do |ranking, i|
      ranking[:position] = i + 1

      if last_point_level_ranking && ranking[:points] != last_point_level_ranking
        ranking[:new_point_level] = true
      end

      last_point_level_ranking = ranking[:points]
    end
  end


  def substitute_points_from(rankings, enrollments)
    active_player_ids = enrollments.select { |e| e.canceled_at.nil? }.map(&:player_id)

    counted_rankings = rankings.select do |r|
      r[:player_id].in?(active_player_ids)
    end

    @average_points = counted_rankings.inject(0) do |sum, ranking|
      sum += ranking[:points]
    end / counted_rankings.length
  end


  def round
    @round ||= options.fetch(:round)
  end
end
