FactoryBot.define do
  factory :enrollment do
    association :season
    association :player

    active { true }
  end
end
