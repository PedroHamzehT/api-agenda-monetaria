# frozen_string_literal: true

module Sales
  # Class responsible to list payments formatted
  class ListPayments < ApplicationInteractor
    def call
      validate_params! :payments
      list_payments
    end

    private

    def list_payments
      context.list = context.payments.map do |payment|
        { id: payment.id, pay_value: payment.pay_value, date: payment.date.strftime('%Y-%m-%d') }
      end
    end
  end
end
