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

    rounds = Round.joins(:season)
                 .where(seasons: { id: match.round.season_id })
                 .where('rounds.position >= ?', match.round.position)
                 .includes(:rankings)
                 .order(position: :asc)

    rounds.each do |round|
      match_winner_ranking = round.rankings.find do |round_ranking|
        round_ranking.player_id == match.winner_id
      end

      match_looser_ranking = round.rankings.find do |round_ranking|
        round_ranking.player_id == match.looser_id
      end

      match_winner_ranking.points += points_for_winner
      match_winner_ranking.toss_points = match_winner_ranking.points

      match_looser_ranking.points += points_for_looser
      match_looser_ranking.toss_points = match_looser_ranking.points

      match_winner_ranking.handicap += match_looser_ranking.points  # !!!!!! ??????
      match_winner_ranking.relevant = true

      match_winner_ranking.sets_difference += sets_difference_for_winner
      match_winner_ranking.games_difference += games_difference_for_winner

      match_looser_ranking.sets_difference += sets_difference_for_looser
      match_looser_ranking.games_difference += games_difference_for_looser

      if match_been_played?
        match_looser_ranking.handicap += match_winner_ranking.points
        match_looser_ranking.relevant = true
      end

      match_winner_ranking.save!
      match_looser_ranking.save!
    end

    update_rankings_of_winner_opponents
    update_rankings_of_looser_opponents if points_for_looser > 0
  end

  def update_rankings_of_winner_opponents
    opponents = Player.joins(matches: [round: :season])
                    .where('matches.player1_id = ? or matches.player2_id = ?', match.winner_id, match.winner_id) # only players that have common match with match winner
                    .where('matches.set1_player1_score is not null and matches.set1_player2_score is not null')  # only players from matches that have at least started
                    .where.not(players: { id: match.winner_id })          # but exclude the match winner
                    .where(seasons: { id: match.round.season_id })        # only opponents of match season
                    .where('rounds.position < ?', match.round.position)   # only those the winner faced before this match

    rankings = Ranking.joins(:player, round: :season)
                   .where(seasons: { id: match.round.season_id })
                   .where('rounds.position >= ?', match.round.position)
                   .where(players: { id: opponents.ids })

    rankings.map do |ranking|
      ranking.handicap += points_for_winner
      ranking.save!
    end
  end

  def update_rankings_of_looser_opponents
    opponents = Player.joins(matches: [round: :season])
                    .where('matches.player1_id = ? or matches.player2_id = ?', match.looser_id, match.looser_id) # only players that have common match with match looser
                    .where('matches.set1_player1_score is not null and matches.set1_player2_score is not null')  # only players from matches that have at least started
                    .where.not(players: { id: match.looser_id })          # but exclude the match looser
                    .where(seasons: { id: match.round.season_id })        # only opponents of match season
                    .where('rounds.position < ?', match.round.position)   # only those the winner faced before this match

    rankings = Ranking.joins(:player, round: :season)
                   .where(seasons: { id: match.round.season_id })
                   .where('rounds.position >= ?', match.round.position)
                   .where(players: { id: opponents.ids })

    rankings.map do |ranking|
      ranking.handicap += points_for_looser
      ranking.save!
    end
  end

  def points_for_winner
    @points_for_winner ||= looser_won_one_set? ? 2 : 3
  end

  def points_for_looser
    @points_for_looser ||= looser_won_one_set? ? 1 : 0
  end

  def looser_won_one_set?
    @looser_won_one_set ||= NumberOfWonSets.result_for(match: match, player: match.looser) == 1
  end

  def sets_difference_for_winner
    return @sets_difference_for_winner unless @sets_difference_for_winner.nil?

    if !match_been_played?
      @sets_difference_for_winner = 2
    elsif match.player1 == match.winner
      @sets_difference_for_winner = player1_won_sets_count - player2_won_sets_count
    elsif match.player2 == match.winner
      @sets_difference_for_winner = player2_won_sets_count - player1_won_sets_count
    end
  end

  def sets_difference_for_looser
    @sets_difference_for_looser ||= -@sets_difference_for_winner
  end

  def games_difference_for_winner
    return @games_difference_for_winner unless @games_difference_for_winner.nil?

    if !match_been_played?
      @games_difference_for_winner = 12
    elsif match.player1 == match.winner
      @games_difference_for_winner = player1_won_games_count - player2_won_games_count
    elsif match.player2 == match.winner
      @games_difference_for_winner = player2_won_games_count - player1_won_games_count
    end
  end

  def games_difference_for_looser
    @games_difference_for_looser ||= -@games_difference_for_winner
  end

  def player1_won_sets_count
    @player1_won_sets_count ||= NumberOfWonSets.result_for(match: match, player: match.player1)
  end

  def player2_won_sets_count
    @player2_won_sets_count ||= NumberOfWonSets.result_for(match: match, player: match.player2)
  end

  def player1_won_games_count
    @player1_won_games_count ||= NumberOfWonGames.result_for(match: match, player: match.player1)
  end

  def player2_won_games_count
    @player2_won_games_count ||= NumberOfWonGames.result_for(match: match, player: match.player2)
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
    match_been_played ||= match.been_played?
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
