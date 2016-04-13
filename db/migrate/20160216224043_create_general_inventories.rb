class CreateGeneralInventories < ActiveRecord::Migration
  def change
    create_table :general_inventories, :primary_key => :gn_inventory_id do |t|
      t.string :rxcui
      t.string :lot_number
      t.date :expiration_date
      t.integer :current_stock, :default => 0
      t.timestamps null: false
    end
  end
end
