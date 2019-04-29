class CreateMatch < Patterns::Service
  pattr_initialize :attributes

  def call
    initialize_match
    add_players_relations if player1.present? && player2.present?
    match.save
    match
  end

  private

  attr_reader :match

  def initialize_match
    @match = Match.new(whitelisted_attributes)
  end

  def add_players_relations
    match.players = [player1, player2]
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
      :note
    )
  end

end
