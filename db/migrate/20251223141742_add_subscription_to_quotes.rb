class AddSubscriptionToQuotes < ActiveRecord::Migration[8.0]
  def change
    add_column :quotes, :subscription, :boolean
  end
end
