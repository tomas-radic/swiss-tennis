class EnrollPlayerToSeason < Patterns::Service
  pattr_initialize :player_id, :season

  def call
    enrollment = nil

    ActiveRecord::Base.transaction do
      enrollment = enroll_player_to_season
      add_rankings! if enrollment.persisted? && current_round.present?
    end

    enrollment
  end

  private

  def enroll_player_to_season
    Enrollment.where(season: season, player: player).first_or_create.tap do |enrollment|
      enrollment.update(canceled: false) if enrollment.persisted?
    end
  end

  def add_rankings!
    most_recent_ranking = Ranking.joins(round: :season)
                              .where(seasons: { id: season.id })
                              .where(rankings: { player_id: player_id })
                              .order('rounds.position asc')
                              .last

    if most_recent_ranking.present?
      season.rounds.where('rounds.position > ?', most_recent_ranking.round.position).each do |round|
        player.rankings.where(round: round).first_or_create!(
            points: most_recent_ranking.points,
            sets_difference: most_recent_ranking.sets_difference,
            games_difference: most_recent_ranking.games_difference,
            relevant: most_recent_ranking.relevant
        )
      end
    else
      player.rankings.where(round: current_round).first_or_create!(
          points: 0, sets_difference: 0, games_difference: 0, relevant: false)
    end
  end

  def player
    @player ||= Player.default.find_by(id: player_id)
  end

  def current_round
    @current_round ||= season.rounds.default.first
  end
end
