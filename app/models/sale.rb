class Sale < ApplicationRecord
  has_many :sale_products
  has_many :products, through: :sale_products

  def update_total
    self.total = sale_products.map(&:total).sum

    self.total = ((total / parcelling) * (1 + tax.to_f / 100)) * parcelling if tax.positive?
  end
end
