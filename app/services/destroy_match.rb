class DestroyMatch < Patterns::Service

  pattr_initialize :match

  def call
    ActiveRecord::Base.transaction do

      update_rankings! if match.finished?
      @match.destroy!
    end
  end


  private

  def update_rankings!
    ActiveRecord::Base.transaction do

      match_outcomes = MatchOutcomes.result_for match: @match

      winner_rankings = rankings.where(rankings: { player_id: @match.winner_id })
      looser_rankings = rankings.where(rankings: { player_id: @match.looser_id })

      winner_rankings.each do |ranking|
        points = ranking.points - match_outcomes[:winner_points]
        sets_difference = ranking.sets_difference - match_outcomes[:winner_sets_difference]
        games_difference = ranking.games_difference - match_outcomes[:winner_games_difference]

        ranking.update!(
          points: points,
          sets_difference: sets_difference,
          games_difference: games_difference)
      end

      looser_rankings.each do |ranking|
        points = ranking.points - match_outcomes[:looser_points]
        sets_difference = ranking.sets_difference + match_outcomes[:winner_sets_difference]
        games_difference = ranking.games_difference + match_outcomes[:winner_games_difference]

        ranking.update!(
          points: points,
          sets_difference: sets_difference,
          games_difference: games_difference)
      end
    end
  end


  def rankings
    @rankings ||= Ranking.joins(round: :season)
                         .where(seasons: { id: @match.round.season_id })
                         .where("rounds.position >= ?", @match.round.position)
  end
end
