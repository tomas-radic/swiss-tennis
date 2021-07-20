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
  # Categories

  puts "\nCreating categories ..."
  categories = [
    { name: "Neregistrovaní", nr_finalists: 2, detail: "aj registrovaní hráči, ktorí sa registrovali až vo veku viac ako 18 rokov" },
    { name: "Registrovaní", nr_finalists: 2, detail: "aj bývalí registrovaní, ktorí mali registráciu vo veku do 18 rokov" },
    { name: "Ženy", nr_finalists: 2 },
    { name: "50r+", nr_finalists: 2 },
    { name: "60r+", nr_finalists: 2 }
  ]

  categories.each do |category|
    record = Category.where(name: category[:name]).first_or_initialize
    record.detail = category[:detail]
    record.nr_finalists = category[:nr_finalists]
    record.save!
  end unless Category.any?

  categories = Category.all

  #
  # Places

  puts "\nCreating places ..."
  ["v parku", "na Mravenisku", "v nemocnici", "u Tobiášovcov"].each do |place_name|
    Place.create!(name: place_name)
  end unless Place.any?

  #
  # Players

  puts "\nCreating players ..."
  unless Player.any?
    this_year = Date.today.year

    20.times do |i|
      Player.create!(
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        email: "player.#{sprintf '%02d', i}@somewhere.com",
        phone: "01234567#{sprintf '%02d', i}",
        birth_year: rand((this_year - 70)..(this_year - 15)),
        consent_given: true,
        category: categories.sample,
        seasons: [season],
        rounds: Round.all.map { |r| r }
      )
    end

    Player.create!(
      dummy: true,
      first_name: 'Večný',
      last_name: 'Looser',
      category: Category.all.sample,
      seasons: [season]
    )
  end

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
        play_time: Match.play_times.keys.sample,
        place: Place.all.sample,
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

      Match.manual.create!(attributes.merge(players: [player1, player2]))
    end
  end unless Match.any?

  #
  # Articles
  
  puts "\nCreating articles ..."
  rand(6..9).times do
    Article.published.create!(
      title: Faker::Lorem.words(number: 2..4).join(' '),
      content: Faker::Lorem.paragraph(sentence_count: 5..25),
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
        description: Faker::Lorem.words(number: 2..3).join(' ')
    )

    payments_count += 1
    Payment.create!(amount: 10000, paid_on: paid_on - 7.days) if payments_count % 5 == 0
    paid_on += 1.month
  end unless Payment.any?

  puts "\nDone."
end
