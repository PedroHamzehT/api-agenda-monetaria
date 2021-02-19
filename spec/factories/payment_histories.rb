FactoryBot.define do
  factory :payment_history do
    pay_value { Faker::Number.decimal(l_digits: 2) }
    date { DateTime.now }
    sale_id { create(:sale).id }
  end
end
