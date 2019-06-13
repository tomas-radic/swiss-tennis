class GameSet
  pattr_initialize :player1_score, :player2_score

  def games_difference
    player1_score - player2_score
  end

  def any_games_played?
    player1_score > 0 || player2_score > 0
  end
end
