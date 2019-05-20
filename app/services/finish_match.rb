class FinishMatch < Patterns::Service
  pattr_initialize :match, :score

  def call
    ActiveRecord::Base.transaction do
      normalize_scores

      begin
        evaluate_played_sets
        set_match_winner
        set_match_score
        mark_match_finished
        update_rankings!
      rescue ScoreInvalidError, RankingMissingError
        return nil
      end

      match.save!
    end

    match
  end

  private

  attr_reader :player1_current_points, :player2_current_points
  attr_reader :set1_player1, :set1_player2, :set2_player1, :set2_player2, :set3_player1, :set3_player2
  attr_reader :player1_sets_won, :player2_sets_won

  class Set
    pattr_initialize :player1_score, :player2_score

    def games_difference
      raise ScoreInvalidError if games_played? && games_equal?
      player1_score - player2_score
    end

    def games_played?
      player1_score > 0 || player2_score > 0
    end

    private

    def games_equal?
      player1_score == player2_score
    end
  end

  def evaluate_played_sets
    sets = [
      Set.new(set1_player1, set1_player2),
      Set.new(set2_player1, set2_player2),
      Set.new(set3_player1, set3_player2)
    ]

    @player1_sets_won = 0
    @player2_sets_won = 0

    sets.each do |set|
      games_difference = set.games_difference

      if games_difference > 0
        @player1_sets_won += 1
      elsif games_difference < 0
        @player2_sets_won += 1
      end
    end
  end

  def set_match_winner
    if player1_sets_won > player2_sets_won
      match.winner = match.player1
    elsif player1_sets_won < player2_sets_won
      match.winner = match.player2
    else
      raise ScoreInvalidError
    end
  end

  def set_match_score
    if Set.new(set1_player1, set1_player2).games_played?
      match.set1_player1_score = set1_player1
      match.set1_player2_score = set1_player2
    end

    if Set.new(set2_player1, set2_player2).games_played?
      match.set2_player1_score = set2_player1
      match.set2_player2_score = set2_player2
    end

    if Set.new(set3_player1, set3_player2).games_played?
      match.set3_player1_score = set3_player1
      match.set3_player2_score = set3_player2
    end
  end

  def mark_match_finished
    match.finished = true
    match.published = true
  end

  def update_rankings!
    raise RankingMissingError if player1_rankings.empty?
    raise RankingMissingError if player2_rankings.empty?

    @player1_current_points ||= match.round.rankings.find_by(player: match.player1).points
    @player2_current_points ||= match.round.rankings.find_by(player: match.player2).points
    update_player1_rankings!
    update_player2_rankings!
  end

  def update_player1_rankings!
    sets_difference_delta = player1_sets_won - player2_sets_won
    games_difference_delta = player1_games_won - player2_games_won

    player1_rankings.each do |ranking|
      ranking.handicap += player2_current_points
      ranking.sets_difference += sets_difference_delta
      ranking.games_difference += games_difference_delta
      ranking.points += 1 if player1_won?
      ranking.relevant = true
      ranking.save!
    end
  end

  def update_player2_rankings!
    sets_difference_delta = player2_sets_won - player1_sets_won
    games_difference_delta = player2_games_won - player1_games_won

    player2_rankings.each do |ranking|
      ranking.handicap += player1_current_points
      ranking.sets_difference += sets_difference_delta
      ranking.games_difference += games_difference_delta
      ranking.points += 1 if player2_won?
      ranking.relevant = true
      ranking.save!
    end
  end

  def player1_won?
    match.winner == match.player1
  end

  def player2_won?
    match.winner == match.player2
  end

  def player1_games_won
    @player1_games_won ||= set1_player1 + set2_player1 + set3_player1
  end

  def player2_games_won
    @player2_games_won ||= set1_player2 + set2_player2 + set3_player2
  end

  def player1_rankings
    @player1_rankings ||= PlayerRankingsSinceRoundQuery.call(player: match.player1, round: match.round)
  end

  def player2_rankings
    @player2_rankings ||= PlayerRankingsSinceRoundQuery.call(player: match.player2, round: match.round)
  end

  def normalize_scores
    @set1_player1 = score[:set1_player1].to_i
    @set1_player2 = score[:set1_player2].to_i
    @set2_player1 = score[:set2_player1].to_i
    @set2_player2 = score[:set2_player2].to_i
    @set3_player1 = score[:set3_player1].to_i
    @set3_player2 = score[:set3_player2].to_i
  end

  class ScoreInvalidError < StandardError
  end

  class RankingMissingError < StandardError
  end

  class MatchFinishedError < StandardError
  end
end
