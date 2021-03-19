FactoryBot.define do
  factory :product do
    name { Faker::Food.fruits }
    value { Faker::Number.between(from: 100.0, to: 1000.00).round(2) }
    description { Faker::Food.description }
    user_id { create(:user).id }
  end
end
