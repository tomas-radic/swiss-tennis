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

        winner_current_points = winner_rankings.find { |r| r[:round_id] == round.id }[:points]
        looser_current_points = looser_rankings.find { |r| r[:round_id] == round.id }[:points]
        match_outcomes = MatchOutcomes.result_for(
            match: match,
            winner_current_points: winner_current_points,
            looser_current_points: looser_current_points)

        winner_rankings.each do |ranking|
          ranking[:points] += match_outcomes[:winner_points]
          ranking[:sets_difference] += match_outcomes[:winner_sets_difference]
          ranking[:games_difference] += match_outcomes[:winner_games_difference]
          ranking[:handicap] += match_outcomes[:winner_handicap_increase]
          ranking[:relevant] = true
        end unless match.winner.dummy?

        looser_rankings.each do |ranking|
          ranking[:points] += match_outcomes[:looser_points]
          ranking[:sets_difference] += (-match_outcomes[:winner_sets_difference])
          ranking[:games_difference] += (-match_outcomes[:winner_games_difference])

          if match.been_played?
            ranking[:handicap] += match_outcomes[:looser_handicap_increase]
            ranking[:relevant] = true
          end
        end unless match.looser.dummy?

        update_rewardable_opponents(match_outcomes[:winner_points], match.winner, match.round, resulting_rankings)
        update_rewardable_opponents(match_outcomes[:looser_points], match.looser, match.round, resulting_rankings) if match_outcomes[:looser_points] > 0
      end
    end

    resulting_rankings
  end

  def update_rewardable_opponents(handicap_points, player, round, all_rankings)
    rewardable_opponents = RewardableOpponentsQuery.call(player: player, round: round)
    rewardable_opponents = rewardable_opponents.where(dummy: false)

    rankings_of_rewardable_opponents = all_rankings.select do |ranking|
      ranking[:round_position] >= round.position && rewardable_opponents.map(&:id).include?(ranking[:player_id])
    end

    rankings_of_rewardable_opponents.map do |ranking|
      ranking[:handicap] += handicap_points
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
