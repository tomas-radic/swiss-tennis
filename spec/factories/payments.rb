FactoryBot.define do
  factory :payment do
    amount { 10000 }
    paid_on { 10.days.ago }
    description { '' }
  end
end
