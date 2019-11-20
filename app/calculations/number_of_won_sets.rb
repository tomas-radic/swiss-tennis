class NumberOfWonSets < Patterns::Calculation

  private

  attr_reader :number_of_won_sets

  def result
    return 0 if player_not_related_to_match?

    count_scores_in_sets
    @number_of_won_sets = number_of_won_sets_for_player
    apply_retirement_override if retired_player.present?

    number_of_won_sets
  end

  def count_scores_in_sets
    @scores_in_sets_for_player = [
        match.set1_player1_score.to_i - match.set1_player2_score.to_i,
        match.set2_player1_score.to_i - match.set2_player2_score.to_i,
        match.set3_player1_score.to_i - match.set3_player2_score.to_i
    ]

    if player == match.player2
      @scores_in_sets_for_player.map! { |score_in_set| -score_in_set }
    end
  end

  def number_of_won_sets_for_player
    method_result = 0

    number_of_played_sets = @scores_in_sets_for_player.length

    @scores_in_sets_for_player.map.with_index do |score_in_set, index|
      break if (index + 1) == number_of_played_sets && retired_player.present?

      method_result += 1 if score_in_set > 0
    end

    method_result
  end

  def apply_retirement_override
    if (player == match.player2 && retired_player == match.player1) ||
        (player == match.player1 && retired_player == match.player2)

      @number_of_won_sets = 2
    end
  end

  def player_not_related_to_match?
    player != match.player1 && player != match.player2
  end

  def retired_player
    @retired_player ||= match.retired_player
  end

  def match
    @match ||= options.fetch(:match)
  end

  def player
    @player ||= options.fetch(:player)
  end
end