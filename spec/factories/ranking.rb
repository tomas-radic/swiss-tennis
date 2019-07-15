FactoryBot.define do
  factory :ranking do
    association :player
    association :round

    points { 0 }
    toss_points { 0 }
    handicap { 0 }
    sets_difference { 0 }
    games_difference { 0 }
    relevant { false }

    trait :relevant do
      relevant { true }
    end
  end
end
