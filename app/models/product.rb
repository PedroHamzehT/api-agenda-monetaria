class Product < ApplicationRecord
  validates_presence_of :name, :value

  has_many :clients, through: :product_client
end
