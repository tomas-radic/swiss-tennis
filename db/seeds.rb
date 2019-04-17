# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#

#
# Users
puts "\nCreating users ..."
%w{tomas.radic@gmail.com ondrejemilbabala@gmail.com}.each do |email|
  User.create!(email: email, password: 'nbusr123')
end unless User.any?

#
# Seasons

puts "\nCreating seasons ..."
Season.create!(name: '2019') unless Season.any?
season = Season.all.order(:created_at).last

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
20.times do
  Player.create!(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    email: Faker::Internet.email,
    phone: Faker::PhoneNumber.cell_phone,
    birth_year: rand(1960..2000),
    category: categories.sample
  )
end unless Player.any?

#
# Rounds

puts "\nCreating rounds ..."
ROUNDS_TO_CREATE = 3

ROUNDS_TO_CREATE.times do |i|
  round_begin_date = Date.today - ((ROUNDS_TO_CREATE - i - 1) * 2).weeks

  round = season.rounds.new(
    period_begins: round_begin_date,
    period_ends: round_begin_date + 2.weeks,
    closed: i < (ROUNDS_TO_CREATE - 1)
  )

  players = Player.all.to_a
  matches = []

  while players.length > 1 do
    player1 = players.delete(players.sample)
    player2 = players.delete(players.sample)
    winner = nil
    finished = false

    if i < (ROUNDS_TO_CREATE - 1)  # unless last round
      winner = [player1, player2].sample
      finished = true
    end

    round.matches.manual.new(player1: player1, player2: player2, winner: winner, published: true)
  end

  round.save!
end unless Round.any?

puts "\nDone."
