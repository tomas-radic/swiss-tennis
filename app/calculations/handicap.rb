class Handicap < Patterns::Calculation

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

    # binding.pry
    opponents_rankings = round_rankings.select do |round_ranking|
      opponents_ids.include?(round_ranking[:player_id]) && (round_ranking[:round].position == ranking.round.position)
    end

    opponents_rankings.inject(0) { |handicap, opponent_ranking| handicap += opponent_ranking[:points] }
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
end
