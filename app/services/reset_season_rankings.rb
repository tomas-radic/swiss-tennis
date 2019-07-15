class ResetSeasonRankings < Patterns::Service
  pattr_initialize :season

  def call
    reset_season_rankings!
  end

  private

  def reset_season_rankings!
    match_been_played = Proc.new do |match|
      (match.set1_player1_score && match.set1_player1_score > 0) ||
      (match.set1_player2_score && match.set1_player2_score > 0)
    end

    rankings = Ranking.joins(:round).where(rounds: { season_id: season.id })
    puts "\n\nFound #{rankings.count} rankings."

    ranking_hashes = []

    rankings.each do |ranking|
      ranking_hashes << {
        id: ranking.id,
        round_id: ranking.round_id,
        player_id: ranking.player_id,
        player_name: ranking.player.name,
        round_position: ranking.round.position,
        points: 0,
        toss_points: 0,
        handicap: 0,
        sets_difference: 0,
        games_difference: 0,
        relevant: false
      }
    end

    season.rounds.order(position: :asc).each do |round|
      puts "\n\n------------------------"
      puts "Round #{round.full_label}..."

      round.matches.finished.each do |match|
        puts "\nMatch #{MatchDecorator.new(match).label}"
        puts "W #{match.winner.name}"
        puts "L #{match.looser.name}"

        winner_rankings = ranking_hashes.select do |h|
          h[:round_position] >= round.position && h[:player_id] == match.winner.id
        end

        looser_rankings = ranking_hashes.select do |h|
          h[:round_position] >= round.position && h[:player_id] == match.looser.id
        end

        puts "Rankings before this match:"
        puts "WR #{winner_rankings.to_s}"
        puts "LR #{looser_rankings.to_s}"

        winner_sets_delta = SetsDelta.result_for(match: match, player: match.winner)
        winner_games_delta = GamesDelta.result_for(match: match, player: match.winner)
        looser_sets_delta = SetsDelta.result_for(match: match, player: match.looser)
        looser_games_delta = GamesDelta.result_for(match: match, player: match.looser)
        match_played = match_been_played.call(match)

        winner_rankings.each do |ranking|
          ranking[:points] += 1
          ranking[:toss_points] = ranking[:points]
          ranking[:handicap] += looser_rankings.first[:points]
          ranking[:sets_difference] += winner_sets_delta
          ranking[:games_difference] += winner_games_delta
          ranking[:relevant] = true
        end

        looser_rankings.each do |ranking|
          ranking[:handicap] += winner_rankings.first[:points]
          ranking[:sets_difference] += looser_sets_delta
          ranking[:games_difference] += looser_games_delta
          ranking[:relevant] = true if match_played
        end

        puts "Rankings after this match"
        puts "WR #{winner_rankings.to_s}"
        puts "LR #{looser_rankings.to_s}"


        winner_opponents = PlayerOpponentsUpToRoundQuery.call(player: match.winner, round: round)
        puts "Previous winner opponents: #{winner_opponents.map { |wo| [wo.first_name, wo.last_name].join(' ') }.join(' | ')}"

        winner_opponents.each do |opponent|
          puts "Updating ranking for #{opponent.name}"
          opponent_rankings = ranking_hashes.select do |h|
            h[:round_position] >= round.position && h[:player_id] == opponent.id
          end

          opponent_rankings.each do |ranking|
            ranking[:handicap] += 1
          end

          puts "#{opponent.name}\n#{opponent_rankings.to_s}"
        end

        puts "Ok."
      end
    end

    puts "Importing into DB..."
    columns_to_update = [
      :points,
      :toss_points,
      :handicap,
      :sets_difference,
      :games_difference,
      :relevant
    ]

    Ranking.import ranking_hashes.map { |h| h.except(:player_name, :round_position) },
        on_duplicate_key_update: { conflict_target: [:id], columns: columns_to_update }

    puts "\nDone.\n"
  end
end
