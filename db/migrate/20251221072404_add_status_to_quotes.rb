class AddStatusToQuotes < ActiveRecord::Migration[8.0]
  def change
    add_column :quotes, :status, :string
    add_column :quotes, :default, :string
    add_column :quotes, :Pending, :string
  end
end
