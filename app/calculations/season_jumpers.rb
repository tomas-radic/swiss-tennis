class SeasonJumpers < Patterns::Calculation

  private

  def result
    jumpers = []
    return jumpers if current_round.blank? || previous_season_round.blank?

    current_rankings = rankings_for(current_round)
    previous_rankings = rankings_for(previous_season_round)


    current_rankings.each do |cr|
      previous_season_ranking = previous_rankings.find { |pr| pr[:player].id == cr[:player].id }
      next unless previous_season_ranking

      jumpers << {
          player: cr[:player],
          previous_position: previous_season_ranking[:recalculated_position],
          current_position: cr[:recalculated_position],
          jump: previous_season_ranking[:recalculated_position] - cr[:recalculated_position]
      }
    end

    jumpers.sort_by! do |j|
      [-j[:jump], j[:current_position]]
    end

    minimum_match_count = previous_season.rounds.regular.count - 1
    previous_season_matches = previous_season.matches.includes(:player1, :player2)

    jumpers.delete_if do |jumper|
      played_matches_count = previous_season_matches.select do |match|
        match.been_played? && (match.player1 == jumper[:player] || match.player2 == jumper[:player])
      end.length

      played_matches_count < minimum_match_count
    end

    jumpers
  end


  def relevant_players
    @relevant_players ||= previous_season.players.where(id: current_season.players.ids)
  end



  def current_season
    @current_season ||= options.fetch(:season)
  end


  def previous_season
    @previous_season ||= Season.default.where("position < ?", current_season.position).first
  end


  def current_round
    return nil if current_season.nil?

    @current_round ||= current_season.rounds.default.regular.first
  end


  def previous_season_round
    return nil if previous_season.nil?

    @previous_season_round ||= previous_season.rounds.default.regular.first
  end


  def rankings_for(round)
    relevant_players_ids = relevant_players.ids

    result = SortedRankings.result_for(round: round).select do |r|
      r[:player].id.in? relevant_players_ids
    end

    result.map!.with_index do |r, i|
      r[:recalculated_position] = i + 1
      r
    end
  end
end
