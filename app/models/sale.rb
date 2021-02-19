class Sale < ApplicationRecord
  has_many :sale_products
  has_many :products, through: :sale_products

  def update_total
    self.total = sale_products.map(&:total).sum
  end
end
