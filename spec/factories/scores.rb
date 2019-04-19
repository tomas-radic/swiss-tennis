FactoryBot.define do
  factory :score do
    player { nil }
    round { nil }
    points { 1 }
    handicap { 1 }
    games_difference { 1 }
  end
end
