# frozen_string_literal: true

module PaymentHistories
  class CreatePayments < ApplicationInteractor
    def call
      validate_params! :payments, :sale_id
      find_sale
      create_payments
    end

    private

    def find_sale
      context.sale = Sale.find_by_id(context.sale_id)
    end

    def create_payments
      context.payments.each do |payment|
        sale_payment = PaymentHistory.find_by_id(payment.delete(:id))
        sale_payment ? update(payment, sale_payment) : create(payment)
      end
    end

    def create(payment)
      context.sale.payment_histories.create(payment)
    end

    def update(payment, sale_payment)
      sale_payment.update(payment)
    end
  end
end
