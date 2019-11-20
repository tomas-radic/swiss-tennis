class GamesDelta < Patterns::Calculation

  private

  def result
    count_retirement_override

    if player == match.player1
      games_delta
    elsif player == match.player2
      -games_delta
    end
  end

  def match
    @match ||= options.fetch(:match)
  end

  def player
    @player ||= options.fetch(:player)
  end

  def games_delta
    @games_delta ||= (
      player1_games_won - player2_games_won
    )
  end

  def player1_games_won
    @player1_games_won ||= match.set1_player1_score.to_i +
        match.set2_player1_score.to_i + match.set3_player1_score.to_i
  end

  def player2_games_won
    @player2_games_won ||= match.set1_player2_score.to_i +
        match.set2_player2_score.to_i + match.set3_player2_score.to_i
  end

  def count_retirement_override
    return if match.been_played?

    @player1_games_won = 12 if player2_retired?
    @player2_games_won = 12 if player1_retired?
  end

  def player1_retired?
    match.retired_player == match.player1
  end

  def player2_retired?
    match.retired_player == match.player2
  end
end
