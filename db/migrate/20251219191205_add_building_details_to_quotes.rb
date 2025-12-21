class AddBuildingDetailsToQuotes < ActiveRecord::Migration[8.0]
  def change
    add_column :quotes, :building_type, :string
   # add_column :quotes, :floors, :integer
  end
end
