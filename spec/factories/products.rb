FactoryBot.define do
  factory :product do
    name { Faker::Food.fruits }
    value { Faker::Number.decimal(l_digits: 2) }
    description { Faker::Food.description }
  end
end
