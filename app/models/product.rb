class Product < ApplicationRecord
  validates_presence_of :name
  validates :value, numericality: { greater_than: 0 }

  has_many :sales, through: :sale_products
  belongs_to :user
end
