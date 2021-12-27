# frozen_string_literal: true

class CreateSaleProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :sale_products do |t|
      t.integer :sale_id, null: false, foreign_key: true
      t.integer :product_id, null: false, foreign_key: true

      t.timestamps
    end
  end
end
