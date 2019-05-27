class FinishMatch < Patterns::Service
  pattr_initialize :match, :score, [:retirement]

  def call
    ActiveRecord::Base.transaction do
      normalize_scores

      begin
        count_won_sets
        set_match_winner
        set_match_score
        mark_match_finished
        update_rankings!
      rescue ScoreInvalidError, RankingMissingError => e
        return nil
      end

      match.save!
    end

    match
  end

  private

  attr_reader :player1_current_points, :player2_current_points
  attr_reader :set1_player1, :set1_player2, :set2_player1, :set2_player2, :set3_player1, :set3_player2
  attr_reader :played_sets_count, :player1_sets_won, :player2_sets_won

  class Set
    pattr_initialize :player1_score, :player2_score

    def games_difference
      # raise ScoreInvalidError if !match_retired? && games_played? && games_equal?
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

  def count_won_sets
    sets = []
    sets << Set.new(set1_player1, set1_player2) if set1_player1 > 0 || set1_player2 > 0
    sets << Set.new(set2_player1, set2_player2) if set2_player1 > 0 || set2_player2 > 0
    sets << Set.new(set3_player1, set3_player2) if set3_player1 > 0 || set3_player2 > 0

    @played_sets_count = sets.length
    @player1_sets_won = 0
    @player2_sets_won = 0

    sets.each_with_index do |set, i|
      break if match_retired? && ((i + 1) == played_sets_count) # don't count the last set if retirement

      games_difference = set.games_difference

      if games_difference > 0
        @player1_sets_won += 1
      elsif games_difference < 0
        @player2_sets_won += 1
      end
    end
  end

  def set_match_winner
    if player1_retired?
      match.retired_player = match.player1
      match.winner = match.player2
    elsif player2_retired?
      match.retired_player = match.player2
      match.winner = match.player1
    elsif player1_sets_won > player2_sets_won
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
      if played_sets_count > 0
        ranking.sets_difference += sets_difference_delta
        ranking.games_difference += games_difference_delta
      end

      ranking.handicap += player2_current_points if played_sets_count > 0 || !player1_retired?
      ranking.points += 1 if player1_won?
      ranking.relevant = true
      ranking.save!
    end
  end

  def update_player2_rankings!
    sets_difference_delta = player2_sets_won - player1_sets_won
    games_difference_delta = player2_games_won - player1_games_won

    player2_rankings.each do |ranking|
      if played_sets_count > 0
        ranking.sets_difference += sets_difference_delta
        ranking.games_difference += games_difference_delta
      end

      ranking.handicap += player1_current_points if played_sets_count > 0 || !player2_retired?
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

  def match_retired?
    @match_retired ||= retirement && retirement[:retired_player_id].present?
  end

  def player1_retired?
    @player1_retired ||= match_retired? && retirement[:retired_player_id] == match.player1_id
  end

  def player2_retired?
    @player2_retired ||= match_retired? && retirement[:retired_player_id] == match.player2_id
  end

  class ScoreInvalidError < StandardError
  end

  class RankingMissingError < StandardError
  end

  class MatchFinishedError < StandardError
  end
end
