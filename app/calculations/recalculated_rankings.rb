class RecalculatedRankings < Patterns::Calculation

  private

  def result
    recalculated_rankings
  end

  def recalculated_rankings
    resulting_rankings = rankings.map do |ranking|
      {
          id: ranking.id,
          round_id: ranking.round_id,
          player_id: ranking.player_id,
          player_name: ranking.player.name,
          round_position: ranking.round.position,
          points: 0,
          handicap: 0,
          sets_difference: 0,
          games_difference: 0,
          relevant: false
      }
    end

    rounds.each do |round|
      round.matches.finished.each do |match|
        winner_rankings = resulting_rankings.select do |ranking|
          ranking[:player_id] == match.winner_id && ranking[:round_position] >= round.position
        end

        looser_rankings = resulting_rankings.select do |ranking|
          ranking[:player_id] == match.looser_id && ranking[:round_position] >= round.position
        end

        looser_won_one_set = NumberOfWonSets.result_for(match: match, player: match.looser) == 1
        winner_current_points = winner_rankings.find { |r| r[:round_id] == round.id }[:points]
        looser_current_points = looser_rankings.find { |r| r[:round_id] == round.id }[:points]
        points_for_winner = points_for_winner(looser_won_one_set)
        points_for_looser = points_for_looser(looser_won_one_set)
        points_to_winner_handicap = looser_current_points + points_for_looser
        points_to_looser_handicap = winner_current_points + points_for_winner
        sets_difference_for_winner = looser_won_one_set ? 1 : 2
        sets_difference_for_looser = -sets_difference_for_winner
        games_difference_for_winner = games_difference_for_winner(match)
        games_difference_for_looser = -games_difference_for_winner

        winner_rankings.each do |ranking|
          ranking[:points] += points_for_winner
          ranking[:sets_difference] += sets_difference_for_winner
          ranking[:games_difference] += games_difference_for_winner
          ranking[:handicap] += points_to_winner_handicap
          ranking[:relevant] = true
        end

        looser_rankings.each do |ranking|
          ranking[:points] += points_for_looser
          ranking[:sets_difference] += sets_difference_for_looser
          ranking[:games_difference] += games_difference_for_looser

          if match.been_played?
            ranking[:handicap] += points_to_looser_handicap
            ranking[:relevant] = true
          end
        end

        update_rewardable_opponents(points_for_winner, match.winner, match.round, resulting_rankings)
        update_rewardable_opponents(points_for_looser, match.looser, match.round, resulting_rankings) if points_for_looser > 0
      end
    end

    resulting_rankings
  end

  def update_rewardable_opponents(handicap_points, player, round, all_rankings)
    rewardable_opponents = RewardableOpponentsQuery.call(player: player, round: round)

    rankings_of_rewardable_opponents = all_rankings.select do |ranking|
      ranking[:round_position] >= round.position && rewardable_opponents.map(&:id).include?(ranking[:player_id])
    end

    rankings_of_rewardable_opponents.map do |ranking|
      ranking[:handicap] += handicap_points
    end
  end

  def points_for_winner(looser_won_one_set)
    looser_won_one_set ? FinishMatch::WINNER_POINTS_LOST_ONE_SET : FinishMatch::WINNER_POINTS_NO_LOST_SET
  end

  def points_for_looser(looser_won_one_set)
    looser_won_one_set ? FinishMatch::LOOSER_POINTS_WON_ONE_SET : FinishMatch::LOOSER_POINTS_NO_WON_SET
  end

  def looser_won_one_set?(match)
    NumberOfWonSets.result_for(match: match, player: match.looser) == 1
  end

  def games_difference_for_winner(match)
    if match.been_played?
      NumberOfWonGames.result_for(match: match, player: match.winner) -
          NumberOfWonGames.result_for(match: match, player: match.looser)
    else
      12
    end
  end

  def rounds
    @rounds ||= Round.joins(:season)
                    .where(seasons: { id: season.id })
                    .order(position: :asc)
                    .includes(:rankings, :matches)
  end

  def season
    @season ||= options.fetch(:season)
  end

  def rankings
    @rankings ||= Ranking.joins(:round)
        .where(rounds: { season_id: season.id })
        # .includes(:round, :player)
  end
end
