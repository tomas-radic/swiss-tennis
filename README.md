# swiss-tennis

- This web application has been developed for the new tennis competition being played in my original
hometown organised by my friend. It is a voluntary non-profit project just to make
the competition happen.

- The public pages display planned and completed matches and rankings of players switchable
by individual rounds.

- The organizer of the competition can sign in and manage the players, rounds and matches. It includes functionality for automatic swiss tossing system for next rounds to be played.

## Ruby version
- 2.5.3

## Rails version
- 5.2.3

## Database creation
- rails db:migrate:reset

## Database seeds
- rails db:seed

## How to run the test suite
- bundle exec rspec spec

## Start the server
- rails s

## Visit homepage
- http://localhost:3000

## Tasks to run on deployed app
- rails data:create_users
- rails data:create_categories
- rails data:create_dummy_player
- rails data:create_season
- rails data:enroll_players_to_most_recent_season
