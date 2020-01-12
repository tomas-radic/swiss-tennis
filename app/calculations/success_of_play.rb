class SuccessOfPlay < Patterns::Calculation
  private

  def result
    won_games_in_season = 0
    all_games_in_season = 0
    won_games_in_history = 0
    all_games_in_history = 0

    player.matches.published.includes(:round).each do |match|
      player1_games = match.set1_player1_score.to_i + match.set2_player1_score.to_i + match.set3_player1_score.to_i
      player2_games = match.set1_player2_score.to_i + match.set2_player2_score.to_i + match.set3_player2_score.to_i

      match_games = player1_games + player2_games

      all_games_in_history += match_games
      all_games_in_season += match_games if match.round.season_id == season.id

      if match.player1 == player
        won_games_in_history += player1_games
        won_games_in_season += player1_games if match.round.season_id == season.id
      elsif match.player2 == player
        won_games_in_history += player2_games
        won_games_in_season += player2_games if match.round.season_id == season.id
      end
    end

    {
        history: all_games_in_history > 0 ? (won_games_in_history * 100.0 / all_games_in_history).round : nil,
        season: all_games_in_season > 0 ? (won_games_in_season * 100.0 / all_games_in_season).round : nil
    }
  end

  def player
    @player ||= options.fetch(:player)
  end

  def season
    @season ||= options.fetch(:season)
  end
end
