# frozen_string_literal: true

# Class for create Sale model and bind with sales table
class Sale < ApplicationRecord
  validates_presence_of :sale_date

  has_many :sale_products, dependent: :destroy
  has_many :products, through: :sale_products
  has_many :payment_histories, dependent: :destroy

  belongs_to :client

  def update_total
    set_total
    self.total = ((total / parcelling) * (1 + tax.to_f / 100)) * parcelling if tax.positive?

    save!
  end

  def update_paid
    self.paid = true if payment_histories.map(&:pay_value).sum >= total

    save!
  end

  private

  def set_total
    self.total = sale_products.map(&:total).sum
  end
end
