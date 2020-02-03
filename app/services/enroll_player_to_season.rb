class EnrollPlayerToSeason < Patterns::Service
  pattr_initialize :player_id, :season

  def call
    enrollment = nil

    ActiveRecord::Base.transaction do
      enrollment = enroll_player_to_season
      add_ranking! if player.present? && current_round.present?
    end

    enrollment
  end

  private

  def enroll_player_to_season
    Enrollment.where(season: season, player: player).first_or_create.tap do |enrollment|
      enrollment.update(canceled: false)
    end
  end

  def add_ranking!
    player.rankings.where(round: current_round).first_or_create!
  end

  def player
    @player ||= Player.default.find_by(id: player_id)
  end

  def current_round
    @current_round ||= season.rounds.default.first
  end
end
