require 'rails_helper'

RSpec.describe PaymentHistory, type: :model do
  context 'valid values' do
    it 'should create payment_history' do
      create(:payment_history)

      expect(PaymentHistory.all.size).to eq(1)
    end
  end

  context 'invalid values' do
    it 'date blank should not be valid'

    it 'pay_value blank should not be valid'
  end
end
