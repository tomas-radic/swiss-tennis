FactoryBot.define do
  factory :player do
    association :category

    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    phone { Faker::PhoneNumber.cell_phone }
    email { Faker::Internet.email }

    trait :dummy do
      dummy { true }
    end

    trait :inactive do
      active { false }
    end
  end
end
