class TossRoundMatches < Patterns::Service
  pattr_initialize :round, :toss_points, [:mandatory_player_ids]

  TOSS_VARIANTS_COUNT = 10

  def call
    return if toss_points.blank?

    create_toss_players
    assign_exlusions_to_toss_players
    create_several_toss_variants
    compute_toss_variants_suitabilities
    create_toss_matches!
  end

  private

  def create_toss_players
    @toss_players = []
    @exclusions = {}

    players.each do |player|
      next if toss_points[player.id].nil?

      toss_player = TossPlayer.new
      toss_player.id = player.id
      toss_player.delta = toss_points[player.id].to_i
      @toss_players << toss_player

      opponents = Player.joins(matches: [round: :season])
          .where(seasons: { id: round.season_id })
          .where('matches.player1_id = ? or matches.player2_id = ?', player.id, player.id)
          .where('players.id != ?', player.id)
      @exclusions[player.id] = opponents.map(&:id)
    end
  end

  def assign_exlusions_to_toss_players
    @toss_players.each do |toss_player|
      toss_player.exclude = @toss_players.select { |tp| @exclusions[toss_player.id].include?(tp.id) }
    end
  end

  def create_several_toss_variants
    @toss_variants = []

    TOSS_VARIANTS_COUNT.times do
      @toss_variants << Swissper.pair(@toss_players)
    end
  end

  def compute_toss_variants_suitabilities
    @toss_variants_suitabilities = {}

    @toss_variants.each do |toss_variant|
      toss_variant_suitability = 0

      toss_variant.each do |players_pair|
        court_player = players_pair[0]
        balls_player = players_pair[1]

        next unless court_player.instance_of?(TossRoundMatches::TossPlayer)
        next unless balls_player.instance_of?(TossRoundMatches::TossPlayer)
        next if court_player_counts[court_player.id].nil? || court_player_counts[balls_player.id].nil?
        next if court_player_counts[court_player.id] == court_player_counts[balls_player.id]

        if court_player_counts[court_player.id] > court_player_counts[balls_player.id]
          players_pair.reverse!
        end

        toss_variant_suitability += 1
      end

      @toss_variants_suitabilities[toss_variant_suitability] ||= []
      @toss_variants_suitabilities[toss_variant_suitability] << toss_variant
    end
  end

  def create_toss_matches!
    final_variant.each do |pair|
      next unless pair[0].instance_of?(TossRoundMatches::TossPlayer)
      next unless pair[1].instance_of?(TossRoundMatches::TossPlayer)

      court_player_id = pair[0].id
      balls_player_id = pair[1].id

      Match.create!(
        player1_id: court_player_id,
        player2_id: balls_player_id,
        players: [players.find { |p| p[:id] == court_player_id }, players.find { |p| p[:id] == balls_player_id }],
        from_toss: true,
        round_id: round.id,
        published: false
      )
    end
  end

  def final_variant
    @final_variant ||= @toss_variants_suitabilities[@toss_variants_suitabilities.keys.max].sample
  end

  def players
    @players ||= PlayersWithoutMatchQuery.call(round: round)
        .where(id: toss_points.keys)
  end

  def court_player_counts
    @court_player_counts ||= AllPlayersMatchesCountsAsPlayer1.call(round.season).result
  end

  class TossPlayer < Swissper::Player
    attr_accessor :id
  end
end
