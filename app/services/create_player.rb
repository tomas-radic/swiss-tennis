class CreatePlayer < Patterns::Service
  pattr_initialize :attributes, :season

  def call
    initialize_player
    add_ranking if current_round.present?

    player.save
    player
  end

  private

  attr_reader :player

  def initialize_player
    @player = Player.new(whitelisted_attributes.merge(seasons: [season]))
  end

  def current_round
    @current_round ||= season.rounds.open.first
  end

  def add_ranking
    player.rankings = [
      current_round.rankings.new(
        player: player,
        points: 0,
        handicap: 0,
        sets_difference: 0,
        games_difference: 0,
        relevant: false
      )
    ]
  end

  def whitelisted_attributes
    @whitelisted_attributes ||= attributes.slice(
      :first_name, :last_name, :phone, :email, :birth_year, :category_id
    )
  end
end
