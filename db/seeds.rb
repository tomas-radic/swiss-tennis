# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

#
# Methods

def sample_match_score(winner_idx)
  result = {}

  if winner_idx == 0
    result[:set1_player1_score] = 6
    result[:set2_player1_score] = 6
    result[:set1_player2_score] = rand(0..4)
    result[:set2_player2_score] = rand(0..4)
  else
    result[:set1_player1_score] = rand(0..4)
    result[:set2_player1_score] = rand(0..4)
    result[:set1_player2_score] = 6
    result[:set2_player2_score] = 6
  end

  result
end

def sample_round_ranking_attributes_for(player, round_index)
  points = rand(0..(round_index + 1))

  {
    player: player,
    points: points,
    toss_points: points,
    handicap: rand(0..round_index),
    sets_difference: rand(-5..7),
    games_difference: rand(-15..20),
    relevant: true
  }
end

ActiveRecord::Base.transaction do

  #
  # Users
  puts "\nCreating users ..."
  %w{tomas.radic@gmail.com ondrejemilbabala@gmail.com}.each do |email|
    User.create!(email: email, password: 'password')
  end unless User.any?

  #
  # Seasons

  puts "\nCreating seasons ..."
  Season.create!(name: Date.today.year.to_s) unless Season.any?
  season = Season.default.first

  #
  # Categories

  puts "\nCreating categories ..."
  %w{60r+ 50r+ Registrovaný Neregistrovaný}.each do |category|
    Category.create!(name: category)
  end unless Category.any?

  categories = Category.all

  #
  # Players

  puts "\nCreating players ..."
  unless Player.any?
    20.times do
      Player.create!(
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        email: Faker::Internet.email,
        phone: Faker::PhoneNumber.cell_phone,
        birth_year: rand(1960..2000),
        consent_given: true,
        category: categories.sample,
        seasons: [season]
      )
    end

    category = Category.find_by(name: 'Neregistrovaný')
    Player.create!(
      dummy: true,
      first_name: 'Večný',
      last_name: 'Looser',
      category: category,
      seasons: [season]
    )
  end

  #
  # Rounds

  puts "\nCreating rounds ..."
  ROUNDS_TO_CREATE = 3

  ROUNDS_TO_CREATE.times do |i|
    round_begin_date = Date.today - ((ROUNDS_TO_CREATE - i - 1) * 2).weeks

    round = season.rounds.create!(
      period_begins: round_begin_date,
      period_ends: round_begin_date + 2.weeks,
      closed: i < (ROUNDS_TO_CREATE - 1)
    )
  end unless Round.any?

  #
  # Matches

  puts "\nCreating matches ..."
  Round.all.each_with_index do |round, i|
    players = Player.default.to_a
    matches = []

    while players.length > 1 do
      player1 = players.delete(players.sample)
      player2 = players.delete(players.sample)
      attributes = {
        round: round,
        player1: player1,
        player2: player2,
        published: true
      }

      # Finish matches of previous rounds and some of the current last round
      if (i < (ROUNDS_TO_CREATE - 1)) || (rand(0..2) == 0)
        winner_idx = rand(0..1)
        assigned_players = [player1, player2]
        winner = assigned_players.delete(assigned_players[winner_idx])
        looser = assigned_players.first
        attributes[:winner] = winner
        attributes[:looser] = looser
        attributes[:finished] = true
        attributes.merge!(sample_match_score(winner_idx))
      end

      match = Match.manual.create!(attributes.merge(players: [player1, player2]))

      round.rankings.create!(sample_round_ranking_attributes_for(player1, i))
      round.rankings.create!(sample_round_ranking_attributes_for(player2, i))
    end
  end unless Match.any?

  #
  # Articles
  
  puts "\nCreating articles ..."
  rand(6..9).times do
    Article.published.create!(
      title: Faker::Lorem.words(2..4).join(' '),
      content: Faker::Lorem.paragraph(5..25),
      user: User.all.sample,
      season: season
    )
  end unless Article.any?

  #
  # Payments

  puts "\nCreating payments ..."
  paid_on = 1.year.ago.to_date - 5.days
  payments_count = 0

  while paid_on < Date.today do
    Payment.create!(
        amount: -rand(650..850),
        paid_on: paid_on,
        description: Faker::Lorem.words(number: rand(2..3)).join(' ')
    )

    payments_count += 1
    Payment.create!(amount: 10000, paid_on: paid_on - 7.days) if payments_count % 5 == 0
    paid_on += 1.month
  end unless Payment.any?

  puts "\nDone."
end
