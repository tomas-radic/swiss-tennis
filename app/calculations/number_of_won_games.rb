class NumberOfWonGames < Patterns::Calculation

  private

  attr_reader :set1_player1, :set1_player2,
              :set2_player1, :set2_player2,
              :set3_player1, :set3_player2

  def result
    return 0 if player_not_related_to_match?

    if player == match.player1
      set1_player1 + set2_player1 + set3_player1
    elsif player == match.player2
      set1_player2 + set2_player2 + set3_player2
    end
  end

  #
  # Dynamic methods

  3.times do |set_index|
    set_number = set_index + 1

    2.times do |player_index|
      player_number = player_index + 1

      define_method "set#{set_number}_player#{player_number}".to_sym do
        instance_variable_symbol = "@set#{set_number}_player#{player_number}".to_sym

        unless instance_variable_defined?(instance_variable_symbol)
          score = match.send("set#{set_number}_player#{player_number}_score").to_i
          instance_variable_set(instance_variable_symbol, score)
        end

        instance_variable_get(instance_variable_symbol)
      end
    end
  end

  #
  # Instance methods

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