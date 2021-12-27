# frozen_string_literal: true

class AddColumnsToSaleProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :sale_products, :quantity, :integer, default: 1
    add_column :sale_products, :total, :float, default: 0
  end
end
