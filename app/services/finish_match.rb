class FinishMatch < Patterns::Service
  pattr_initialize :match, :score

  def call
    ActiveRecord::Base.transaction do
      normalize_scores

      begin
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

  def set_match_winner
    sets = [
      Set.new(set1_player1, set1_player2),
      Set.new(set2_player1, set2_player2),
      Set.new(set3_player1, set3_player2)
    ]

    player1 = 0
    player2 = 0

    sets.each do |set|
      games_difference = set.games_difference

      if games_difference > 0
        player1 += 1
      elsif games_difference < 0
        player2 += 1
      end
    end

    if player1 > player2
      match.winner = match.player1
    elsif player1 < player2
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
    raise RankingMissingError if player1_ranking.nil? || player2_ranking.nil?
    @player1_current_points = player1_ranking.points
    @player2_current_points = player2_ranking.points
    update_player1_ranking!
    update_player2_ranking!
  end

  def update_player1_ranking!
    player1_ranking.handicap += player2_current_points
    player1_ranking.games_difference += (player1_games_won - player2_games_won)
    player1_ranking.points += 1 if player1_won?
    player1_ranking.save!
  end

  def update_player2_ranking!
    player2_ranking.handicap += player1_current_points
    player2_ranking.games_difference += (player2_games_won - player1_games_won)
    player2_ranking.points += 1 if player2_won?
    player2_ranking.save!
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

  def player1_ranking
    @player1_ranking ||= match.round.rankings.find_by(player: match.player1)
  end

  def player2_ranking
    @player2_ranking ||= match.round.rankings.find_by(player: match.player2)
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
end
