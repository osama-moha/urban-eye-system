class AddEmailToLeads < ActiveRecord::Migration[8.0]
  def change
    add_column :leads, :email, :string
  end
end
