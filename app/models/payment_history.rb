class PaymentHistory < ApplicationRecord
  after_save :update_sale_status

  validates_presence_of :date
  validates :pay_value, numericality: { greater_than: 0 }

  belongs_to :sale

  private

  def update_sale_status
    sale.update_paid
  end
end
