class CreateMatch < Patterns::Service
  pattr_initialize :attributes

  def call
    validate_enrollments_of_players!

    initialize_match
    add_players_relations if player1.present? && player2.present?
    @match.save

    @match
  end

  private

  def validate_enrollments_of_players!
    return unless round.present?

    if player1.present?
      player_enrollment = player1.enrollments.active.find_by(season: round.season)
      raise PlayerInvalidError unless player_enrollment.present?
      raise PlayerInvalidError unless player1.rounds.include?(round)
    end

    if player2.present?
      player_enrollment = player2.enrollments.active.find_by(season: round.season)
      raise PlayerInvalidError unless player_enrollment.present?
      raise PlayerInvalidError unless player2.rounds.include?(round)
    end
  end

  def initialize_match
    @match = Match.new(whitelisted_attributes)
  end

  def add_players_relations
    @match.players = [player1, player2]
  end

  def round
    @round ||= Round.find_by(id: attributes[:round_id])
  end

  def player1
    @player1 ||= Player.find_by(id: attributes[:player1_id])
  end

  def player2
    @player2 ||= Player.find_by(id: attributes[:player2_id])
  end

  def whitelisted_attributes
    @whitelisted_attributes ||= attributes.slice(
      :player1_id,
      :player2_id,
      :from_toss,
      :round_id,
      :published,
      :play_date,
      :play_time,
      :place_id,
      :note
    )
  end

  class PlayerInvalidError < StandardError
  end
end
