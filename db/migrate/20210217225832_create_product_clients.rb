class CreateProductClients < ActiveRecord::Migration[6.0]
  def change
    create_table :product_clients do |t|
      t.references :product_id, null: false, foreign_key: true
      t.references :client_id, null: false, foreign_key: true
      t.references :sale_id, null: false, foreign_key: true
      t.integer :quantity

      t.timestamps
    end
  end
end
