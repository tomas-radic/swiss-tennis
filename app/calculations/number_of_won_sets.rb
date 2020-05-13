class NumberOfWonSets < Patterns::Calculation

  private

  def result
    return 0 if player_not_related_to_match?

    player_balance.select { |s| s > 0 }.length
  end

  def player_balance
    return @player_balance unless @player_balance.nil?

    @player_balance = []

    3.times do |set_index|
      set_number = set_index + 1
      player1_set_score = match.send(:"set#{set_number}_player1_score").to_i
      player2_set_score = match.send(:"set#{set_number}_player2_score").to_i

      if finished_set?(set_number, player1_set_score, player2_set_score)
        @player_balance << player1_set_score - player2_set_score
      end
    end

    if player == match.player2
      @player_balance.map! { |score_in_set| -score_in_set }
    end

    @player_balance
  end

  def finished_set?(set_number, player1_score, player2_score)
    lowest_score, highest_score = [player1_score, player2_score].sort
    return true if highest_score >= 7
    return true if set_number == 3 && highest_score == 1 && lowest_score == 0
    highest_score == 6 && lowest_score < 5
  end

  def player_not_related_to_match?
    player != match.player1 && player != match.player2
  end

  def match
    @match ||= options.fetch(:match)
  end

  def player
    @player ||= options.fetch(:player)
  end
end