class CreateLeads < ActiveRecord::Migration[8.0]
  def change
    create_table :leads do |t|
      t.string :name
      t.string :phone
      t.string :property_type
      t.string :location

      t.timestamps
    end
  end
end
