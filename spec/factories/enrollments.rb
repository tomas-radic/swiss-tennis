FactoryBot.define do
  factory :enrollment do
    association :season
    association :player

    active { true }

    trait :canceled do
      canceled { true }
    end
  end
end
