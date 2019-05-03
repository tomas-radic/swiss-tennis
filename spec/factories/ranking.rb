FactoryBot.define do
  factory :ranking do
    association :player
    association :round

    points { 1 }
    handicap { 1 }
    games_difference { 1 }
  end
end
