# frozen_string_literal: true

class ChangeColumnTotalInSales < ActiveRecord::Migration[6.0]
  def change
    change_column :sales, :total, :float, default: 0
  end
end
