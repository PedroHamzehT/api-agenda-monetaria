class CreatePaymentHistories < ActiveRecord::Migration[6.0]
  def change
    create_table :payment_histories do |t|
      t.references :sale_id, null: false, foreign_key: true
      t.float :pay_value
      t.datetime :date

      t.timestamps
    end
  end
end
