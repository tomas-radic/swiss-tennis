class CreateRound < Patterns::Service
  pattr_initialize :attributes

  def call
    new_round = season.rounds.new(whitelisted_attributes)

    season.players.each do |player|
      last_ranking = last_ranking_for(player)

      if last_ranking.present?
        new_round.rankings.new(
          player: player,
          points: last_ranking.points,
          handicap: last_ranking.handicap,
          games_difference: last_ranking.games_difference
        )
      else
        new_round.rankings.new(
          player: player,
          points: 0,
          handicap: 0,
          games_difference: 0
        )
      end
    end

    new_round.save!
    new_round
  end

  private

  def season
    @season ||= Season.order(:created_at).last
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
