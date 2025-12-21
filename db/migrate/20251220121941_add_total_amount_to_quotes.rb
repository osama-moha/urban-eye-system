class AddTotalAmountToQuotes < ActiveRecord::Migration[8.0]
  def change
    add_column :quotes, :total_amount, :decimal, precision: 10, scale: 2
  end
end
