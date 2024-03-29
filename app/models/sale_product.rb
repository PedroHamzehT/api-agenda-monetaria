# frozen_string_literal: true

# Class for create SaleProduct model and bind with sale_products table
class SaleProduct < ApplicationRecord
  before_save :set_total
  after_save :update_total_sale

  belongs_to :sale
  belongs_to :product

  private

  def set_total
    self.total = product.value * quantity
  end

  def update_total_sale
    sale.update_total
  end
end
