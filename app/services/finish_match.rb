class FinishMatch < Patterns::Service
  pattr_initialize :match, :score, [:retirement]

  def call
    ActiveRecord::Base.transaction do
      normalize_scores

      begin
        set_match_score
        set_match_winner_and_looser
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

  attr_reader :set1_player1, :set1_player2, :set2_player1, :set2_player2, :set3_player1, :set3_player2
  attr_reader :remembered_winner_points

  def set_match_winner_and_looser
    if player1_retired?
      match.retired_player = match.player1
      match.looser = match.player1
      match.winner = match.player2
    elsif player2_retired?
      match.retired_player = match.player2
      match.looser = match.player2
      match.winner = match.player1
    elsif player1_sets_delta > 0
      match.winner = match.player1
      match.looser = match.player2
    elsif player2_sets_delta > 0
      match.winner = match.player2
      match.looser = match.player1
    else
      raise ScoreInvalidError
    end
  end

  def set_match_score
    if set1_player1 > 0 || set1_player2 > 0
      match.set1_player1_score = set1_player1
      match.set1_player2_score = set1_player2
    end

    if set2_player1 > 0 || set2_player2 > 0
      match.set2_player1_score = set2_player1
      match.set2_player2_score = set2_player2
    end

    if set3_player1 > 0 || set3_player2 > 0
      match.set3_player1_score = set3_player1
      match.set3_player2_score = set3_player2
    end
  end

  def mark_match_finished
    match.finished = true
    match.published = true
  end

  def update_rankings!
    raise RankingMissingError if winner_rankings.empty?
    raise RankingMissingError if looser_rankings.empty?

    update_winner_rankings!
    update_looser_rankings!
    update_opponents_handicaps!
  end

  def update_winner_rankings!
    winner_rankings.each do |ranking|
      ranking.points += 1
      ranking.toss_points = ranking.points
      @remembered_winner_points ||= ranking.points
      ranking.handicap += looser_rankings.first.points
      ranking.sets_difference += winner_sets_delta
      ranking.games_difference += winner_games_delta
      ranking.relevant = true if match_been_played? || player2_retired?

      ranking.save!
    end
  end

  def update_looser_rankings!
    looser_rankings.each do |ranking|
      ranking.toss_points = ranking.points
      ranking.handicap += remembered_winner_points
      ranking.sets_difference += looser_sets_delta
      ranking.games_difference += looser_games_delta
      ranking.relevant = true if match_been_played?

      ranking.save!
    end
  end

  def update_opponents_handicaps!
    winner_opponents = PlayerOpponentsUpToRoundQuery.call(player: match.winner, round: match.round)

    winner_opponents.each do |opponent|
      opponent_rankings_to_update = PlayerRankingsSinceRoundQuery.call(player: opponent, round: match.round)

      opponent_rankings_to_update.each do |ranking|
        ranking.handicap += 1
        ranking.save!
      end
    end
  end

  def match_been_played?
    set1_player1 > 0 || set1_player2 > 0
  end

  def player1_won?
    match.winner == match.player1
  end

  def player2_won?
    match.winner == match.player2
  end

  def player1_sets_delta
    @player1_sets_delta ||= SetsDelta.result_for(match: match, player: match.player1)
  end

  def player2_sets_delta
    @player2_sets_delta ||= -player1_sets_delta
  end

  def player1_games_delta
    @player1_games_delta ||= GamesDelta.result_for(match: match, player: match.player1)
  end

  def player2_games_delta
    @player2_games_delta ||= -player1_games_delta
  end

  def winner_sets_delta
    if player1_won?
      player1_sets_delta
    elsif player2_won?
      player2_sets_delta
    end
  end

  def looser_sets_delta
    if player1_won?
      player2_sets_delta
    elsif player2_won?
      player1_sets_delta
    end
  end

  def winner_games_delta
    if player1_won?
      player1_games_delta
    elsif player2_won?
      player2_games_delta
    end
  end

  def looser_games_delta
    if player1_won?
      player2_games_delta
    elsif player2_won?
      player1_games_delta
    end
  end

  def winner_rankings
    @winner_rankings ||= PlayerRankingsSinceRoundQuery.call(player: match.winner, round: match.round)
  end

  def looser_rankings
    @looser_rankings ||= PlayerRankingsSinceRoundQuery.call(player: match.looser, round: match.round)
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
