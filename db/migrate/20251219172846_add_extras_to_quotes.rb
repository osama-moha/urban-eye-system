class AddExtrasToQuotes < ActiveRecord::Migration[8.0]
  def change
    add_column :quotes, :recording_days, :integer
    add_column :quotes, :monitor, :boolean
    add_column :quotes, :ups, :boolean
  end
end
