class AddLocationToQuotes < ActiveRecord::Migration[8.0]
  def change
    add_column :quotes, :location, :string
  end
end
