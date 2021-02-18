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

  it 'total should be calculated by products values and quantity'

  it 'when parcelling is greater than 1 should calculate the values'

  it 'when there is a tax should calculate the values'

  it 'when history_payment sum be equal the sale total, sale should be paid'
end
