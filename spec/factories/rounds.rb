FactoryBot.define do
  factory :round do
    association :season

    period_begins { "2019-04-14" }
    period_ends { "2019-04-14" }
    closed { false }

    trait :specific do
      specific_purpose { true }
    end
  end
end
