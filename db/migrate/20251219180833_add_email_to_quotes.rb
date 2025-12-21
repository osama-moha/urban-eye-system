class AddEmailToQuotes < ActiveRecord::Migration[8.0]
  def change
    add_column :quotes, :email, :string
  end
end
