FactoryBot.define do
  factory :player do
    association :category

    first_name { "Roger" }
    last_name { "Federer" }
    phone { "0901 222 333" }
    email { "roger@federer.com" }

    trait :dummy do
      dummy { true }
    end
  end
end
