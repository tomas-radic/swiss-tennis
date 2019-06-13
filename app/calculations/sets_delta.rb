class SetsDelta < Patterns::Calculation

  private

  attr_reader :player1_sets_won, :player2_sets_won

  def result
    count_completed_sets
    count_retirement_override

    if player == match.player1
      sets_delta
    elsif player == match.player2
      -sets_delta
    end
  end

  def sets_delta
    @sets_delta ||= (player1_sets_won - player2_sets_won)
  end

  def count_completed_sets
    sets = []
    sets << GameSet.new(set1_player1, set1_player2) if set1_player1 > 0 || set1_player2 > 0
    sets << GameSet.new(set2_player1, set2_player2) if set2_player1 > 0 || set2_player2 > 0
    sets << GameSet.new(set3_player1, set3_player2) if set3_player1 > 0 || set3_player2 > 0

    played_sets_count = sets.length
    @player1_sets_won = 0
    @player2_sets_won = 0

    sets.each_with_index do |set, i|
      # don't count the last set if retirement
      last_set = (i + 1) == played_sets_count
      break if player1_retired? && last_set
      break if player2_retired? && last_set

      games_difference = set.games_difference

      if games_difference > 0
        @player1_sets_won += 1
      elsif games_difference < 0
        @player2_sets_won += 1
      end
    end
  end

  def count_retirement_override
    @player1_sets_won = 2 if player2_retired?
    @player2_sets_won = 2 if player1_retired?
  end

  def match
    @match ||= options.fetch(:match)
  end

  def player
    @player ||= options.fetch(:player)
  end

  def player1_retired?
    match.retired_player == match.player1
  end

  def player2_retired?
    match.retired_player == match.player2
  end

  def set1_player1
    @set1_player1 ||= match.set1_player1_score.to_i
  end

  def set1_player2
    @set1_player2 ||= match.set1_player2_score.to_i
  end

  def set2_player1
    @set2_player1 ||= match.set2_player1_score.to_i
  end

  def set2_player2
    @set2_player2 ||= match.set2_player2_score.to_i
  end

  def set3_player1
    @set3_player1 ||= match.set3_player1_score.to_i
  end

  def set3_player2
    @set3_player2 ||= match.set3_player2_score.to_i
  end
end
