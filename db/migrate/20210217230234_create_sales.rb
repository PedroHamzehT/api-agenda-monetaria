class CreateSales < ActiveRecord::Migration[6.0]
  def change
    create_table :sales do |t|
      t.float :total
      t.integer :parceling
      t.integer :tax
      t.boolean :paid

      t.timestamps
    end
  end
end
