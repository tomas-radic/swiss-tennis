FactoryBot.define do
  factory :ranking do
    association :player
    association :round

    points { 1 }
    toss_points { 1 }
    handicap { 1 }
    sets_difference { 1 }
    games_difference { 1 }
    relevant { false }

    trait :relevant do
      relevant { true }
    end
  end
end
