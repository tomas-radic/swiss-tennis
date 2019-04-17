FactoryBot.define do
  factory :match do
    association :player1, factory: :player
    association :player2, factory: :player
    association :round

    type { 'MatchManual' }
    published { true }
  end
end
