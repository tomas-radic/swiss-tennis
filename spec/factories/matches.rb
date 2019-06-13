FactoryBot.define do
  factory :match do
    association :round

    from_toss { false }
    published { true }

    before(:create) do |match|
      match.player1 ||= create(:player)
      match.player2 ||= create(:player)

      match.players = [match.player1, match.player2]
    end

    trait :finished do |match|
      before(:create) do |match|
        match.winner ||= match.player1
        match.looser ||= match.player2
      end

      finished { true }
      set1_player1_score { 6 }
      set1_player2_score { rand(0..4) }
      set2_player1_score { 6 }
      set2_player2_score { rand(0..4) }
    end

    trait :draft do
      published { false }
    end
  end
end
