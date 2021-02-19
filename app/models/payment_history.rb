class PaymentHistory < ApplicationRecord
  validates_presence_of :date
  validates :pay_value, numericality: { greater_than: 0 }

  belongs_to :sale
end
