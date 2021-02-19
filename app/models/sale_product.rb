class SaleProduct < ApplicationRecord
  before_save :set_total

  belongs_to :sale
  belongs_to :product

  private

  def set_total
    self.total = product.value * quantity
  end
end
