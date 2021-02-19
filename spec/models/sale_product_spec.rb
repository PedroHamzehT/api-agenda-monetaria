require 'rails_helper'

RSpec.describe SaleProduct, type: :model do
  it 'should calculate the total' do
    sale_product = create(:sale_product)

    expect(sale_product.total).to eq(sale_product.product.value * sale_product.quantity)
  end
end
