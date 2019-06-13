class GamesDelta < Patterns::Calculation

  private

  def result
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
      match.set1_player1_score.to_i + match.set2_player1_score.to_i + match.set3_player1_score.to_i -
      match.set1_player2_score.to_i - match.set2_player2_score.to_i - match.set3_player2_score.to_i
    )
  end
end
