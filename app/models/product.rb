class Product < ApplicationRecord
  validates_presence_of :name
  validates :value, numericality: { greater_than: 0 }

  has_many :clients, through: :product_client
end
