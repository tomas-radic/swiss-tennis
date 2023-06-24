class TossRoundMatches < Patterns::Service
  pattr_initialize :round, :toss_points, [:mandatory_player_ids]

  def call
    return if toss_points.blank?

    create_toss_players
    assign_exlusions_to_toss_players

    matches = Match.joins(round: :season)
                   .where('seasons.id = ?', round.season_id)
                   .where('matches.published is true')

    p1_counts = matches.group('matches.player1_id').count
    p2_counts = matches.group('matches.player2_id').count

    toss = Swissper.pair(@toss_players) # [[p1, p2], [p3, p4]]

    toss.each do |pair| # [p1, p2]
      p1 = pair[0]
      p2 = pair[1]

      next unless p1.instance_of?(TossRoundMatches::TossPlayer)
      next unless p2.instance_of?(TossRoundMatches::TossPlayer)

      diff1 = p1_counts[p1.id].to_i - p2_counts[p1.id].to_i
      diff2 = p1_counts[p2.id].to_i - p2_counts[p2.id].to_i

      if diff1 > 0 # player1 had more matches at position 1
        if diff2 > 0 # player2 had more matches at position 1
          pair.reverse! if diff1 > diff2
        elsif diff2 <= 0 # player2 balanced or had more matches at position 2
          pair.reverse!
        end
      elsif diff1 == 0 # player1 balanced
        if diff2 < 0 # player2 had more matches at position 2
          pair.reverse!
        end
      elsif diff1 < 0 # player1 had more matches at position 2
        if diff2 < 0 #player2 had more matches at position 2
          pair.reverse! if diff2 < diff1
        end
      end

      Match.create!(
        player1_id: pair[0].id,
        player2_id: pair[1].id,
        players: [players.find { |p| p[:id] == pair[0].id }, players.find { |p| p[:id] == pair[1].id }],
        from_toss: true,
        round_id: round.id,
        published: false
      )
    end
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


  def players
    @players ||= PlayersWithoutMatchQuery.call(round: round)
        .where(id: toss_points.keys)
  end

  class TossPlayer < Swissper::Player
    attr_accessor :id
  end
end
