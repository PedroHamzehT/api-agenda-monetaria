require 'rails_helper'

RSpec.describe Sale, type: :model do
  context 'valid values' do
    it 'should create sale' do
      create(:sale)

      expect(Sale.all.size).to eq(1)
    end
  end

  context 'invalid values' do
    it 'sale_date blank should not be valid' do
      sale = build(:sale, sale_date: nil)

      expect(sale).to_not be_valid
    end
  end

  it 'total should be calculated by products values and quantity' do
    product = create(:product, value: 5.2)
    sale_product = create(:sale_product, product_id: product.id, quantity: 2)

    expect(sale_product.sale.total).to eq(5.2 * 2)
  end

  it 'when there is a tax should calculate the values' do
    product = create(:product, value: 5.2)
    sale = create(:sale, parcelling: 2, tax: 2)
    create(:sale_product, sale_id: sale.id, product_id: product.id, quantity: 2)

    value_to_be_paid = ((sale.total / sale.parcelling) * (1 + sale.tax.to_f / 100)) * sale.parcelling

    expect(sale.total).to eq(value_to_be_paid)
  end

  it 'when payment_history sum be equal the sale total, sale should be paid' do
    sale_product = create(:sale_product)

    total = sale_product.product.value * sale_product.quantity
    create(:payment_history, pay_value: total, sale_id: sale_product.sale.id)

    expect(Sale.last.paid).to eq(true)
  end
end
