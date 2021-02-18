class Product < ApplicationRecord
  validates_presence_of :name, :value

  belongs_to :client, through: :product_client
end
