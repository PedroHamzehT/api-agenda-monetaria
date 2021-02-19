require 'rails_helper'

RSpec.describe Product, type: :model do
  context 'valid values' do
    it 'should create product' do
      create(:product)

      expect(Product.all.size).to eq(1)
    end
  end

  context 'invalid values' do
    it 'name blank should not be valid' do
      product = build(:product, name: '')

      expect(product).to_not be_valid
    end

    it 'value equal 0 should not be valid' do
      product = build(:product, value: nil)

      expect(product).to_not be_valid
    end
  end
end
