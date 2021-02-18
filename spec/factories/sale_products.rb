FactoryBot.define do
  factory :sale_product do
    sale_id { create(:sale).id }
    product_id { create(:product).id }
    quantity { Faker::Number.number(digits: 1) }
  end
end
