FactoryBot.define do
  factory :payment_history do
    sale_id { create(:sale).id }
    pay_value { Faker::Number.decimal(l_digits: 2) }
    date { DateTime.now }
  end
end
