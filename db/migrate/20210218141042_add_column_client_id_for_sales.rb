class AddColumnClientIdForSales < ActiveRecord::Migration[6.0]
  def change
    add_column :sales, :client_id, :integer, null: false, foreign_key: true
  end
end
