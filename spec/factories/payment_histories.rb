FactoryBot.define do
  factory :payment_history do
    pay_value { Faker::Number.between(from: 100.0, to: 2000.00).round(2) }
    date { DateTime.now }
    sale_id { create(:sale).id }
  end
end
