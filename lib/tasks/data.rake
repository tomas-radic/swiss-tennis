namespace :data do
  desc "Creates default users"
  task create_users: :environment do
    %w{tomas.radic@gmail.com ondrejemilbabala@gmail.com}.each do |email|
      user = User.find_by(email: email)

      if user.nil?
        puts "Creating #{email} ..."
        User.create!(email: email, password: 'password')
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

  desc "Creates season"
  task create_season: :environment do
    %w{2019}.each do |season|
      puts "Creating #{season} ..."
      Season.where(name: season).first_or_create!
    end

    puts 'Done.'
  end

  desc "Enroll all existing players to the most recent season"
  task enroll_players_to_most_recent_season: :environment do
    season = SelectedSeason.result_for(season_id: nil)

    if season.present?
      Player.all.each do |player|
        Enrollment.where(season: season, player: player).first_or_create!
      end
    else
      puts 'Season not found.'
    end

    puts 'Done.'
  end

  desc 'Analyzes existing rankings based on matches played in given season, outputs possible differences'
  task output_season_rankings_errors: :environment do
    season = Season.all.order(:created_at).first

    if season
      OutputSeasonRankingsErrors.call(season)
    else
      puts 'Season not found.'
    end
  end

  desc 'Resets existing rankings based on matches played in given season'
  task reset_season_rankings: :environment do
    season = Season.all.order(:created_at).first

    if season
      ResetSeasonRankings.call(season)
    else
      puts 'Season not found.'
    end
  end
end
