class Sale < ApplicationRecord
  validates_presence_of :sale_date

  has_many :sale_products
  has_many :products, through: :sale_products
  has_many :payment_histories

  def update_total
    self.total = sale_products.map(&:total).sum

    self.total = ((total / parcelling) * (1 + tax.to_f / 100)) * parcelling if tax.positive?

    save!
  end

  def update_paid
    self.paid = true if payment_histories.map(&:pay_value).sum >= total

    save!
  end
end
