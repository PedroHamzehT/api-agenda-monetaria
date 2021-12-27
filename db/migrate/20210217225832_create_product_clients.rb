# frozen_string_literal: true

class CreateProductClients < ActiveRecord::Migration[6.0]
  def change
    create_table :product_clients do |t|
      t.integer :product_id, null: false, foreign_key: true
      t.integer :client_id, null: false, foreign_key: true
      t.integer :sale_id, null: false, foreign_key: true
      t.integer :quantity

      t.timestamps
    end
  end
end
