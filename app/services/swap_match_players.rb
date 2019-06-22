class SwapMatchPlayers < Patterns::Service
  pattr_initialize :match

  def call
    return if match.finished?
    swap_match_players!
  end

  private

  def swap_match_players!
    p1 = match.player1
    match.player1 = match.player2
    match.player2 = p1
    match.save!
  end
end
