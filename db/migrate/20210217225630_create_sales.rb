# frozen_string_literal: true

class CreateSales < ActiveRecord::Migration[6.0]
  def change
    create_table :sales do |t|
      t.float :total
      t.integer :parceling, default: 1
      t.integer :tax
      t.boolean :paid, default: false
      t.datetime :sale_date

      t.timestamps
    end
  end
end
