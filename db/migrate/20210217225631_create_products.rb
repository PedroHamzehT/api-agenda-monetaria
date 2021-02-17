class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products do |t|
      t.string :name
      t.float :value
      t.text :description

      t.timestamps
    end
  end
end
