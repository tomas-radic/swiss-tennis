FactoryBot.define do
  factory :article do
    association :season
    association :user

    title { Faker::Lorem.words(2..4).join(' ') }
    content { Faker::Lorem.paragraph(5..25) }
    published { true }

    trait :draft do
      published { false }
    end
  end
end
