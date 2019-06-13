namespace :data do
  desc "Creates default users"
  task create_users: :environment do
    %w{tomas.radic@gmail.com ondrejemilbabala@gmail.com}.each do |email|
      user = User.find_by(email: email)

      if user.nil?
        puts "Creating #{email} ..."
        User.create!(email: email, password: 'nbusr123')
      else
        puts "#{email} already exists"
      end
    end

    puts 'Done.'
  end

  desc "Creates default categories"
  task create_categories: :environment do
    %w{60r+ 50r+ Registrovaný Neregistrovaný}.each do |category|
      puts "Creating #{category} ..."
      Category.where(name: category).first_or_create!
    end

    puts 'Done.'
  end

  desc "Creates dummy player"
  task create_dummy_player: :environment do
    dummy_player = Player.find_by(dummy: true)

    if dummy_player.nil?
      puts "Creating dummy player ..."
      category = Category.find_by(name: 'Neregistrovaný')
      Player.create!(dummy: true, first_name: 'Večný', last_name: 'Looser', category: category)
    else
      puts "Dummy player has been existing."
    end

    puts 'Done.'
  end

  desc "Creates first season"
  task create_season: :environment do
    %w{2019}.each do |season|
      puts "Creating #{season} ..."
      Season.where(name: season).first_or_create!
    end

    puts 'Done.'
  end

  desc "Enroll all existing players to first season"
  task enroll_players_to_first_season: :environment do
    season = Season.all.order(:created_at).first

    if season.present?
      Player.all.each do |player|
        Enrollment.where(season: season, player: player).first_or_create!
      end
    else
      puts 'Season not found.'
    end

    puts 'Done.'
  end

  task reset_season_rankings: :environment do
    season = Season.all.order(:created_at).first

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
        handicap: 0,
        sets_difference: 0,
        games_difference: 0,
        relevant: false
      }
    end

    previous_round = nil

    season.rounds.order(position: :asc).each do |round|
      puts "\n\n------------------------"
      puts "Round #{round.full_label}..."

      round.matches.finished.each do |match|
        puts "\nMatch #{MatchDecorator.new(match).label}"
        puts "W #{match.winner.name}"
        puts "L #{match.looser.name}"
        # winner_ranking = match.winner.rankings.find_by(round: round)
        # looser_ranking = match.looser.rankings.find_by(round: round)
        #
        # raise "Missing ranking for #{match.winner.name}" unless winner_ranking.present?
        # raise "Missing ranking for #{match.looser.name}" unless looser_ranking.present?

        winner_rankings = ranking_hashes.select do |h|
          h[:round_position] >= round.position && h[:player_id] == match.winner.id
        end

        looser_rankings = ranking_hashes.select do |h|
          h[:round_position] >= round.position && h[:player_id] == match.looser.id
        end

        # if previous_round
        #   pr_winner_ranking = ranking_hashes.find do |h|
        #     h[:round_id] == previous_round.id && h[:player_id] == winner_ranking[:player_id]
        #   end
        #
        #   pr_looser_ranking = ranking_hashes.find do |h|
        #     h[:round_id] == previous_round.id && h[:player_id] == looser_ranking[:player_id]
        #   end
        #
        #   winner_ranking[:points] = pr_winner_ranking[:points]
        #   winner_ranking[:handicap] = pr_winner_ranking[:handicap] if pr_winner_ranking[:handicap] > winner_ranking[:handicap]
        #   winner_ranking[:sets_difference] = pr_winner_ranking[:sets_difference]
        #   winner_ranking[:games_difference] = pr_winner_ranking[:games_difference]
        #   winner_ranking[:relevant] = pr_winner_ranking[:relevant]
        #   looser_ranking[:points] = pr_looser_ranking[:points]
        #   looser_ranking[:handicap] = pr_looser_ranking[:handicap] if pr_looser_ranking[:handicap] > looser_ranking[:handicap]
        #   looser_ranking[:sets_difference] = pr_looser_ranking[:sets_difference]
        #   looser_ranking[:games_difference] = pr_looser_ranking[:games_difference]
        #   looser_ranking[:relevant] = pr_looser_ranking[:relevant]
        # end

        puts "Rankings before this match:"
        puts "WR #{winner_rankings.to_s}"
        puts "LR #{looser_rankings.to_s}"

        winner_sets_delta = SetsDelta.result_for(match: match, player: match.winner)
        winner_games_delta = GamesDelta.result_for(match: match, player: match.winner)
        looser_sets_delta = SetsDelta.result_for(match: match, player: match.looser)
        looser_games_delta = GamesDelta.result_for(match: match, player: match.looser)
        match_played = match_been_played.call(match)

# binding.pry if round.position == 3 && match.winner.name == 'Miles Hilll'
        winner_rankings.each do |ranking|
          ranking[:points] += 1
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

          # if previous_round
          #   pr_opponent_ranking = ranking_hashes.find do |h|
          #     h[:round_id] == previous_round.id && h[:player_id] == opponent.id
          #   end
          #
          #   opponent_round_ranking[:points] = pr_opponent_ranking[:points]
          #   opponent_round_ranking[:handicap] = pr_opponent_ranking[:handicap] if pr_opponent_ranking[:handicap] > opponent_round_ranking[:handicap]
          #   opponent_round_ranking[:sets_difference] = pr_opponent_ranking[:sets_difference]
          #   opponent_round_ranking[:games_difference] = pr_opponent_ranking[:games_difference]
          #   opponent_round_ranking[:relevant] = pr_opponent_ranking[:relevant]
          # end

          opponent_rankings.each do |ranking|
            ranking[:handicap] += 1
          end

          puts "#{opponent.name}\n#{opponent_rankings.to_s}"
        end

        puts "Ok."
      end

      previous_round = round
    end if season.present?

    puts "Importing into DB..."
    columns_to_update = [
      :points,
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
