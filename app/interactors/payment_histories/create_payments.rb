module PaymentHistories
  class CreatePayments
    include Interactor

    def call
      validate_params!
      find_sale
      create_payments
    end

    private

    def find_sale
      context.sale = Sale.find_by_id(context.sale_id)
    end

    def validate_params!
      raise 'Invalid payments!' if context.payments.blank?
      raise 'Invalid sale id!'     if context.sale_id.blank?
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
