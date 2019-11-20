class FinishMatch2 < Patterns::Service
  pattr_initialize :match, :score, [:attributes]

  def call
    ActiveRecord::Base.transaction do
      normalize_scores

      begin
        set_match_score
        set_match_winner_and_looser
        set_match_attributes
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

  attr_reader :set1_player1, :set1_player2,
              :set2_player1, :set2_player2,
              :set3_player1, :set3_player2

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

  def set_match_attributes
    match.note = attributes[:note]
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

    rounds = Round.default.joins(:season)
                 .where(seasons: { id: match.round.season_id })
                 .where('rounds.position >= ?', match.round.position)
                 .includes(:rankings)

    rounds.each do |round|
      round_winner_ranking = round.rankings.find do |round_ranking|
        round_ranking.player_id == match.winner_id
      end

      round_looser_ranking = round.rankings.find do |round_ranking|
        round_ranking.player_id == match.looser_id
      end

      round_winner_ranking.points += winner_match_points
      round_winner_ranking.toss_points = round_winner_ranking.points

      round_looser_ranking.points += looser_match_points
      round_looser_ranking.toss_points = round_looser_ranking.points

      round_winner_ranking.handicap += round_looser_ranking.points
      round_winner_ranking.relevant = true

      round_winner_ranking.sets_difference += winner_sets_delta
      round_winner_ranking.games_difference += winner_games_delta

      round_looser_ranking.sets_difference += looser_sets_delta
      round_looser_ranking.games_difference += looser_games_delta

      if match.been_played?
        round_looser_ranking.handicap += round_winner_ranking.points
        round_looser_ranking.relevant = true
      end

      round_winner_ranking.save!
      round_looser_ranking.save!
    end


    update_other_opponents_handicaps!
  end

  def winner_match_points
    @winner_match_points ||= looser_won_one_set? ? 2 : 3
  end

  def looser_match_points
    @looser_match_points ||= looser_won_one_set? ? 1 : 0
  end

  def looser_won_one_set?
    NumberOfWonSets.result_for(match: match, player: match.looser) == 1
  end

  def update_other_opponents_handicaps!
    other_winner_opponents = PlayerOpponentsInSeasonQuery.call(
      player: match.winner,
      season: match.round.season
    ).where.not(id: match.looser_id)

    other_winner_opponents.each do |opponent|
      opponent_rankings_to_update = PlayerRankingsSinceRoundQuery.call(player: opponent, round: match.round)

      opponent_rankings_to_update.each do |ranking|
        ranking.handicap += 1
        ranking.save!
      end
    end
  end

  def player1_won?
    match.winner == match.player1
  end

  def player2_won?
    match.winner == match.player2
  end

  def player1_won_sets_count
    @player1_won_sets_count ||= NumberOfWonSets.result_for(match: match, player: match.player1)
  end

  def player2_won_sets_count
    @player2_won_sets_count ||= NumberOfWonSets.result_for(match: match, player: match.player2)
  end

  def player1_sets_delta
    @player1_sets_delta ||= player1_won_sets_count - player2_won_sets_count
  end

  def player2_sets_delta
    @player2_sets_delta ||= -player1_sets_delta
  end

  def player1_won_games_count
    @player1_won_games_count ||= NumberOfWonGames.result_for(match: match, player: match.player1)
  end

  def player2_won_games_count
    @player2_won_games_count ||= NumberOfWonGames.result_for(match: match, player: match.player2)
  end

  def player1_games_delta
    @player1_games_delta ||= player1_won_games_count - player2_won_games_count
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
    @match_retired ||= attributes && attributes[:retired_player_id].present?
  end

  def player1_retired?
    @player1_retired ||= match_retired? && attributes[:retired_player_id] == match.player1_id
  end

  def player2_retired?
    @player2_retired ||= match_retired? && attributes[:retired_player_id] == match.player2_id
  end

  class ScoreInvalidError < StandardError
  end

  class RankingMissingError < StandardError
  end

  class MatchFinishedError < StandardError
  end
end
