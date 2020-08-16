class FinishMatch < Patterns::Service
  pattr_initialize :match, :score, [:attributes]

  WINNER_POINTS_NO_LOST_SET = 3
  WINNER_POINTS_LOST_ONE_SET = 2
  LOOSER_POINTS_WON_ONE_SET = 1
  LOOSER_POINTS_NO_WON_SET = 0

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

  def set_match_winner_and_looser
    if player1_retired?
      match.retired_player = match.player1
      match.looser = match.player1
      match.winner = match.player2
    elsif player2_retired?
      match.retired_player = match.player2
      match.looser = match.player2
      match.winner = match.player1
    elsif player1_won_sets_count > player2_won_sets_count
      match.winner = match.player1
      match.looser = match.player2
    elsif player2_won_sets_count > player1_won_sets_count
      match.winner = match.player2
      match.looser = match.player1
    else
      raise ScoreInvalidError
    end
  end

  def set_match_attributes
    match.note = attributes[:note] unless attributes.blank?
  end

  def set_match_score
    if @set1_player1 > 0 || @set1_player2 > 0
      match.set1_player1_score = @set1_player1
      match.set1_player2_score = @set1_player2
    end

    if @set2_player1 > 0 || @set2_player2 > 0
      match.set2_player1_score = @set2_player1
      match.set2_player2_score = @set2_player2
    end

    if @set3_player1 > 0 || @set3_player2 > 0
      match.set3_player1_score = @set3_player1
      match.set3_player2_score = @set3_player2
    end
  end

  def mark_match_finished
    match.finished = true
    match.published = true
  end

  def update_rankings!
    match_outcomes = MatchOutcomes.result_for(
        match: match,
        winner_current_points: match.round.rankings.find_by(player: match.winner).points,
        looser_current_points: match.round.rankings.find_by(player: match.looser).points)

    rounds.each do |round|
      match_winner_ranking = round.rankings.find do |round_ranking|
        round_ranking.player_id == match.winner_id
      end

      match_looser_ranking = round.rankings.find do |round_ranking|
        round_ranking.player_id == match.looser_id
      end

      match_winner_ranking.relevant = true
      match_winner_ranking.points += match_outcomes[:winner_points]
      match_looser_ranking.points += match_outcomes[:looser_points]

      if !match.player1.dummy? && !match.player2.dummy?
        match_winner_ranking.handicap += match_looser_ranking.points

        match_winner_ranking.sets_difference += match_outcomes[:winner_sets_difference]
        match_winner_ranking.games_difference += match_outcomes[:winner_games_difference]

        match_looser_ranking.sets_difference += (-match_outcomes[:winner_sets_difference])
        match_looser_ranking.games_difference += (-match_outcomes[:winner_games_difference])

        if match_been_played?
          match_looser_ranking.handicap += match_winner_ranking.points
          match_looser_ranking.relevant = true
        end
      end

      match_winner_ranking.save! unless match.winner.dummy?
      match_looser_ranking.save! unless match.looser.dummy?
    end

    update_rewardable_opponents(match_outcomes[:winner_points], match.winner)
    update_rewardable_opponents(match_outcomes[:looser_points], match.looser) if match_outcomes[:looser_points] > 0
  end

  def update_rewardable_opponents(handicap_points, player)
    rewardable_opponents = RewardableOpponentsQuery.call(player: player, round: match.round)
    return unless rewardable_opponents.any?

    rankings = Ranking.joins(:player, round: :season)
                   .where(seasons: { id: match.round.season_id })
                   .where('rounds.position >= ?', match.round.position)
                   .where(players: { id: rewardable_opponents.ids })

    rankings.map do |ranking|
      ranking.handicap += handicap_points
      ranking.save!
    end
  end

  def player1_won_sets_count
    @player1_won_sets_count ||= NumberOfWonSets.result_for(match: match, player: match.player1)
  end

  def player2_won_sets_count
    @player2_won_sets_count ||= NumberOfWonSets.result_for(match: match, player: match.player2)
  end

  def rounds
    @rounds ||= Round.joins(:season)
                  .where(seasons: { id: match.round.season_id })
                  .where('rounds.position >= ?', match.round.position)
                  .order(position: :asc).includes(:rankings)
  end

  def normalize_scores
    @set1_player1 = score[:set1_player1].to_i
    @set1_player2 = score[:set1_player2].to_i
    @set2_player1 = score[:set2_player1].to_i
    @set2_player2 = score[:set2_player2].to_i
    @set3_player1 = score[:set3_player1].to_i
    @set3_player2 = score[:set3_player2].to_i
  end

  def match_been_played?
    @match_been_played ||= match.been_played?
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
