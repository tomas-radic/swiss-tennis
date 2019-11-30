class SeasonRankings < Patterns::Calculation

  private

  def result
    season_rankings
  end

  def season_rankings
    rankings_hashes = []

    rankings.each do |ranking|
      rankings_hashes << {
        id: ranking.id,
        round_id: ranking.round_id,
        player_id: ranking.player_id,
        player_name: ranking.player.name,
        round_position: ranking.round.position,
        points: 0,
        toss_points: 0,
        handicap: 0,
        sets_difference: 0,
        games_difference: 0,
        relevant: false
      }
    end

    season.rounds.order(position: :asc).each do |round|
      round.matches.finished.includes(:winner, :looser).each do |match|
        winner_rankings = rankings_hashes.select do |h|
          h[:round_position] >= round.position && h[:player_id] == match.winner.id
        end

        looser_rankings = rankings_hashes.select do |h|
          h[:round_position] >= round.position && h[:player_id] == match.looser.id
        end

        winner_sets_delta = SetsDelta.result_for(match: match, player: match.winner)
        winner_games_delta = GamesDelta.result_for(match: match, player: match.winner)
        looser_sets_delta = SetsDelta.result_for(match: match, player: match.looser)
        looser_games_delta = GamesDelta.result_for(match: match, player: match.looser)
        match_played = match.been_played?

        winner_rankings.each do |ranking|
          ranking[:points] += 1
          ranking[:toss_points] = ranking[:points]
          ranking[:handicap] += looser_rankings.first[:points]
          ranking[:sets_difference] +=
          ranking[:games_difference] += winner_games_delta
          ranking[:relevant] = true
        end

        looser_rankings.each do |ranking|
          ranking[:handicap] += winner_rankings.first[:points] if match.been_played?
          ranking[:sets_difference] += looser_sets_delta
          ranking[:games_difference] += looser_games_delta
          ranking[:relevant] = true if match_played
        end

        winner_opponents = PlayerOpponentsUpToRoundQuery.call(player: match.winner, round: round)

        winner_opponents.each do |opponent|
          opponent_rankings = rankings_hashes.select do |h|
            h[:round_position] >= round.position && h[:player_id] == opponent.id
          end

          opponent_rankings.each do |ranking|
            ranking[:handicap] += 1
          end
        end
      end
    end

    rankings_hashes
  end

  def winner_sets_delta(match)
    @winner_sets_delta ||= NumberOfWonSets.result_for(match: match, player: match.winner) -
        NumberOfWonSets.result_for(match: match, player: match.looser)
  end

  def looser_sets_delta(match)
    @looser_sets_delta ||= NumberOfWonSets.result_for(match: match, player: match.winner) -
        NumberOfWonSets.result_for(match: match, player: match.looser)
  end

  def winner_games_delta(match)

  end

  def looser_games_delta(match)

  end

  def season
    @season ||= options.fetch(:season)
  end

  def rankings
    @rankings ||= Ranking.joins(:round)
        .where(rounds: { season_id: season.id })
        .includes(:round, :player)
  end
end
