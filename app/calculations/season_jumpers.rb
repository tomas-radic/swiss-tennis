class SeasonJumpers < Patterns::Calculation

  private

  def result
    jumpers = []
    return jumpers if current_round.blank? || previous_season_round.blank?

    current_rankings = rankings_for(current_round)
    previous_rankings = rankings_for(previous_season_round)

    current_rankings.each do |cr|
      previous_season_ranking = previous_rankings.find { |pr| pr[:player].id == cr[:player].id }

      jumpers << {
          player_name: cr[:player].name,
          previous_position: previous_season_ranking[:recalculated_position],
          current_position: cr[:recalculated_position],
          jump: previous_season_ranking[:recalculated_position] - cr[:recalculated_position]
      }
    end

    jumpers.sort_by do |j|
      [-j[:jump], j[:current_position]]
    end
  end


  def relevant_players_ids
    return @relevant_players_ids if @relevant_players_ids

    current_season_players = current_season.players.where(id: previous_season.players)
    previous_season_players = previous_season.players.where(id: current_season_players)

    @relevant_players_ids = Player.where(id: current_season_players + previous_season_players).ids
  end


  def current_season
    @current_season ||= options.fetch(:season)
  end

  def previous_season
    @previous_season ||= Season.default.where("position < ?", current_season.position).first
  end

  def current_round
    return nil if current_season.nil?

    @current_round ||= current_season.rounds.default.first
  end

  def previous_season_round
    return nil if previous_season.nil?

    @previous_season_round ||= previous_season.rounds.default.first
  end

  def rankings_for(round)
    result = SortedRankings.result_for(round: round).select do |r|
      r[:player].id.in? relevant_players_ids
    end

    result.map!.with_index do |r, i|
      r[:recalculated_position] = i + 1
      r
    end
  end
end
