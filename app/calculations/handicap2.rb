class Handicap2 < Patterns::Calculation


  private

  def result
    played_matches = finished_season_matches.select do |match|
      (match[:round] <= ranking.round.position) &&
        (match[:player1_id] == ranking.player_id || match[:player2_id] == ranking.player_id) &&
        (match[:winner_id] == ranking.player_id || (!match[:set1_player1_score].nil? || !match[:set1_player2_score].nil?))
    end

    opponents_ids = played_matches.map do |match|
      [match[:player1_id], match[:player2_id]].reject { |id| id == ranking.player_id }
    end.flatten

    opponents_rankings = round_rankings.select do |round_ranking|
      opponents_ids.include?(round_ranking[:player_id]) &&
        (round_ranking[:round].position == ranking.round.position)
    end

    opponents_rankings.inject(0) do |handicap, opponent_ranking|

      opponent_enrollment = enrollments.find do |e|
        e.player_id == opponent_ranking[:player_id]
      end

      points_to_add = if opponent_enrollment.canceled_at.nil? || (opponent_ranking[:round].period_begins && opponent_enrollment.canceled_at > opponent_ranking[:round].period_begins)
                        opponent_ranking[:points]
                      else
                        opponent_ranking[:points] >= average_points ? opponent_ranking[:points] : average_points
                      end

      handicap += points_to_add
    end
  end


  def ranking
    @ranking ||= options.fetch(:ranking)
  end


  def finished_season_matches
    @finished_season_matches ||= options.fetch(:finished_season_matches)
  end


  def round_rankings
    @round_rankings ||= options.fetch(:round_rankings)
  end


  def enrollments
    @enrollments ||= options.fetch(:enrollments)
  end


  def average_points
    return @average_points if @average_points

    counted_rankings = round_rankings.select do |r|
      r[:player_id].in?(enrollments.select { |e| e.canceled_at.nil? }.map(&:player_id))
    end

    @average_points = counted_rankings.inject(0) do |sum, ranking|
      sum += ranking[:points]
    end / counted_rankings.length
  end
end
