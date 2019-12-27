class NumberOfWonSets < Patterns::Calculation

  private

  attr_reader :number_of_won_sets

  def result
    return 0 if player_not_related_to_match?

    number_of_won_sets_for_player
  end

  def scores_in_sets_for_player
    return @scores_in_sets_for_player unless @scores_in_sets_for_player.nil?

    @scores_in_sets_for_player = []

    3.times do |set_index|
      set_number = set_index += 1
      player1_set_score = match.send(:"set#{set_number}_player1_score").to_i
      player2_set_score = match.send(:"set#{set_number}_player2_score").to_i

      if player1_set_score > 0 || player2_set_score > 0
        @scores_in_sets_for_player << player1_set_score - player2_set_score
      end
    end

    if player == match.player2
      @scores_in_sets_for_player.map! { |score_in_set| -score_in_set }
    end

    @scores_in_sets_for_player
  end

  def number_of_won_sets_for_player
    method_result = 0
    last_set_index = scores_in_sets_for_player.length - 1

    scores_in_sets_for_player.map.with_index do |score_in_set, index|
      break if index == last_set_index && retired_player.present?

      method_result += 1 if score_in_set > 0
    end

    method_result
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