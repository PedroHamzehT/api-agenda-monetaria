require 'rails_helper'

RSpec.describe PaymentHistory, type: :model do
  context 'valid values' do
    it 'should create payment_history' do
      create(:payment_history)

      expect(PaymentHistory.all.size).to eq(1)
    end
  end

  context 'invalid values' do
    it 'date blank should not be valid' do
      payment_history = build(:payment_history, date: nil)

      expect(payment_history).to_not be_valid
    end

    it 'pay_value equal 0 should not be valid' do
      payment_history = build(:payment_history, pay_value: 0)

      expect(payment_history).to_not be_valid
    end
  end
end
