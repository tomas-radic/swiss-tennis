class SuccessOfPlay < Patterns::Calculation
  private

  def result
    won_games = 0
    all_games = 0

    matches = player.matches.published.not_dummy
                    .joins(:round)
                    .where(rounds: { season_id: season.id })

    matches.each do |match|
      player1_games = match.set1_player1_score.to_i + match.set2_player1_score.to_i + match.set3_player1_score.to_i
      player2_games = match.set1_player2_score.to_i + match.set2_player2_score.to_i + match.set3_player2_score.to_i

      match_games = player1_games + player2_games
      all_games += match_games

      if match.player1 == player
        won_games += player1_games
      elsif match.player2 == player
        won_games += player2_games
      end
    end

    {
      season: season,
      won_games: won_games,
      all_games: all_games,
      percentage: percentage(won_games, all_games)
    }
  end

  def percentage(won_games, all_games)
    return 0 if all_games <= 0

    p = (BigDecimal(won_games, 0) / all_games) * 100

    p >= BigDecimal(1, 0) ? p.to_i : p.ceil
  end

  def player
    @player ||= options.fetch(:player)
  end

  def season
    @season ||= options.fetch(:season)
  end
end
