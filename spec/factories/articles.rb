FactoryBot.define do
  factory :article do
    association :season
    association :user

    title { Faker::Lorem.words(number: 2..4).join(' ') }
    content { Faker::Lorem.paragraph(sentence_count: 5..25) }
    published { true }

    trait :published do
      published { true }
    end
    
    trait :draft do
      published { false }
    end
  end
end
