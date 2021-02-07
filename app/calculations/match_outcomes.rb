class MatchOutcomes < Patterns::Calculation
  private

  def result
    raise MatchUnfinishedError unless match.finished?

    match_outcomes = {
        winner_points: 0,
        winner_sets_difference: 0,
        winner_games_difference: 0,
        looser_points: 0,
        looser_handicap_increase: 0
    }

    winner_won_sets_count = NumberOfWonSets.result_for(match: match, player: match.winner)
    looser_won_sets_count = NumberOfWonSets.result_for(match: match, player: match.looser)
    winner_won_games_count = NumberOfWonGames.result_for(match: match, player: match.winner)
    looser_won_games_count = NumberOfWonGames.result_for(match: match, player: match.looser)

    match_outcomes[:looser_points] = points_for_looser(looser_won_sets_count == 1) unless match.looser.dummy?

    unless match.winner.dummy?
      match_outcomes[:winner_points] = points_for_winner(looser_won_sets_count == 1)
      match_outcomes[:winner_sets_difference] = match.been_played? ? winner_won_sets_count - looser_won_sets_count : 2
      match_outcomes[:winner_games_difference] = match.been_played? ? winner_won_games_count - looser_won_games_count : 12
    end

    if match.been_played? && !match.looser.dummy?
      match_outcomes[:looser_handicap_increase] = winner_current_points + match_outcomes[:winner_points]
    end

    match_outcomes
  end

  def points_for_winner(looser_won_one_set)
    looser_won_one_set ? FinishMatch::WINNER_POINTS_LOST_ONE_SET : FinishMatch::WINNER_POINTS_NO_LOST_SET
  end

  def points_for_looser(looser_won_one_set)
    looser_won_one_set ? FinishMatch::LOOSER_POINTS_WON_ONE_SET : FinishMatch::LOOSER_POINTS_NO_WON_SET
  end


  def match
    @match ||= options.fetch(:match)
  end

  def winner_current_points
    @winner_current_points ||= options.fetch(:winner_current_points)
  end

  def looser_current_points
    @looser_current_points ||= options.fetch(:looser_current_points)
  end

  class MatchUnfinishedError < StandardError
  end
end
