class AddDetailsToQuotes < ActiveRecord::Migration[8.0]
  def change
    add_column :quotes, :outdoor_count, :integer
    add_column :quotes, :purpose, :string
  end
end
