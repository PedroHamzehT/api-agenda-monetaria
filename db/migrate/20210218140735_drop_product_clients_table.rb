class DropProductClientsTable < ActiveRecord::Migration[6.0]
  def change
    drop_table :product_clients
  end
end
