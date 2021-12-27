# frozen_string_literal: true

class RenameParcelingColumn < ActiveRecord::Migration[6.0]
  def change
    rename_column :sales, :parceling, :parcelling
  end
end
