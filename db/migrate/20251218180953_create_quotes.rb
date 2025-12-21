class CreateQuotes < ActiveRecord::Migration[8.0]
  def change
    create_table :quotes do |t|
      t.references :lead, null: false, foreign_key: true
      t.integer :camera_count
      t.integer :floors
      t.decimal :estimated_price

      t.timestamps
    end
  end
end
