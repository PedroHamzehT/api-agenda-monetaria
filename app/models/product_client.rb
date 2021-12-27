# frozen_string_literal: true

class ProductClient < ApplicationRecord
  belongs_to :product_id
  belongs_to :client_id
end
