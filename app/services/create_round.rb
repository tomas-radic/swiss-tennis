class CreateRound < Patterns::Service
  pattr_initialize :attributes

  def call
    create_round
  end

  private

  def create_round
    new_round = season.rounds.new(whitelisted_attributes)

    season.players.each do |player|
      last_ranking = last_ranking_for(player)

      if last_ranking.present?
        new_round.rankings.new(
          player: player,
          points: last_ranking.points,
          toss_points: last_ranking.toss_points,
          handicap: last_ranking.handicap,
          sets_difference: last_ranking.sets_difference,
          games_difference: last_ranking.games_difference,
          relevant: last_ranking.relevant
        )
      else
        new_round.rankings.new(
          player: player,
          points: 0,
          toss_points: 0,
          handicap: 0,
          sets_difference: 0,
          games_difference: 0,
          relevant: false
        )
      end
    end

    new_round.save
    new_round
  end

  def season
    @season ||= Season.find(attributes[:season_id])
  end

  def whitelisted_attributes
    @whitelisted_attributes ||= attributes.slice(:label, :period_begins, :period_ends)
  end

  def last_ranking_for(player)
    Ranking.joins(
        'join rounds on rounds.id = rankings.round_id join seasons on seasons.id = rounds.season_id join players on players.id = rankings.player_id')
        .where('seasons.id = ?', season.id)
        .where('players.id = ?', player.id)
        .order('rounds.position desc')
        .first
  end
end
